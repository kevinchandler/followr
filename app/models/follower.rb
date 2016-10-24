class Follower < ActiveRecord::Base

  belongs_to :user

  def self.compose(user)
    client = user.credential.twitter_client rescue nil
    followers_count = client.follower_ids.count rescue nil

    return if client.nil? || followers_count.nil?

    options = {
      source: 'twitter',
      count: followers_count,
      user: user
    }

    create!(options)
  end

  def self.can_compose_for?(user)
    last_entry = user.followers.order('created_at DESC').first rescue nil
    if last_entry.present?
      last_created_hour = last_entry.created_at.to_datetime
        .in_time_zone(Rails.application.config.time_zone)
        .hour
      current_hour = DateTime.now.in_time_zone(Rails.application.config.time_zone).hour
      return false if last_created_hour == current_hour
    end
    true
  end
end
