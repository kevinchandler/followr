class TwitterUnfollowWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(0, 6, 7, 8, 22, 23) }

  def perform
    unless ENV['WORKERS_DRY_RUN'].blank?
      puts 'TwitterUnfollowWorker run but returning due to WORKERS_DRY_RUN env variable'
      return
    end

    User.can_and_wants_twitter_unfollow.find_in_batches(batch_size: 2) do |group|
      group.each do |user|
        begin
          users_to_unfollow = TwitterFollow.unfollowable_users_for(user)
          next if users_to_unfollow.empty?

          client = user.credential.twitter_client rescue nil
          client_muted_ids = client.muted_ids.to_a rescue []
          next unless user.can_twitter_unfollow?

          users_to_unfollow.each do |followed_user|
            begin
              twitter_user_id = followed_user.twitter_user_id.to_i

              # don't unfollow people who the user has manually unmuted
              next unless client_muted_ids.include?(twitter_user_id)

              if client.unfollow(twitter_user_id)
                followed_user.update_attributes(unfollowed: true, unfollowed_at: Time.zone.now)
                client.unmute(twitter_user_id)
                client.friendship_update(twitter_user_id, wants_retweets: true)
              end

            rescue Twitter::Error::Forbidden => e
              if e.message.index('Application cannot perform write actions')
                user.credential.update_attributes(is_valid: false)
              end
            rescue Twitter::Error::Unauthorized => e
              user.credential.update_attributes(is_valid: false)

              if e.message.index 'Read-only application cannot POST.'
                Airbrake.notify(e)
                Credential.update_all(is_valid: false)

                ActionMailer::Base.mail(
                  to: ENV['ADMIN_EMAIL'],
                  subject: 'Twitter has restricted write access',
                  body: 'Subject says it all'
                ).deliver if send_notification?

                Rails.cache.write('read-only-application-notification', true, expires_in: 10.hours)
                raise 'Read-only application cannot POST.'
              end
            rescue Twitter::Error::NotFound
              followed_user.update_attributes(unfollowed: true, unfollowed_at: Time.zone.now)
            rescue => e
              Airbrake.notify(e)
            end
          end
        rescue => e
          Airbrake.notify(e)
        end
      end
    end
  end

  def send_notification?
    cache = Rails.cache.read('read-only-application-notification')
    cache.nil? && true || false
  end
end
