class User < ActiveRecord::Base
  default_scope -> { includes(:credential, :twitter_follow_preference) }

  after_create :init_follow_prefs

  has_many :twitter_follows
  has_many :followers
  has_one :credential, dependent: :destroy
  has_one :twitter_follow_preference, dependent: :destroy

  scope :wants_twitter_follow, -> {
    joins('INNER JOIN twitter_follow_preferences ON (users.id = user_id)')
      .where('user_id IS NOT NULL AND twitter_follow_preferences.mass_follow IS TRUE')
  }
  scope :wants_twitter_unfollow, -> {
    joins('INNER JOIN twitter_follow_preferences ON (users.id = user_id)')
      .where('twitter_follow_preferences.mass_unfollow IS TRUE')
  }

  def self.create_with_omniauth(auth)
    create! do |user|
      user.twitter_uid = auth['uid']
      user.twitter_username = auth['info']['nickname']
      user.name = auth['info']['name']
      Credential.create_with_omniauth(user, auth)
    end
  end

  def rate_limited?
    twitter_follow_preference.rate_limited?
  end

  # true if all is good to start following
  def twitter_check?
    follow_prefs = twitter_follow_preference
    hashtags = follow_prefs.hashtags.tr('#','').split(',')

    client = credential.twitter_client rescue nil
    if client.nil? || hashtags.empty? ||
        (!follow_prefs.want_mass_follow? && !follow_prefs.mass_unfollow) ||
        !credential.is_valid
      return false
    end
    true
  end

  def can_twitter_follow?
    return false unless credential.is_valid
    return false if twitter_follow_preference.rate_limit_until > DateTime.now

    followed_in_last_hour = twitter_follows.where('followed_at > ?', 1.hour.ago)
    return false if followed_in_last_hour.count >= 50
    true
  end

  def can_twitter_unfollow?
    return false unless credential.is_valid

    unfollowed_in_last_hour = twitter_follows.where('unfollowed_at > ?', 1.hour.ago)
    unfollowed_in_last_day = twitter_follows.where('unfollowed_at > ?', 24.hours.ago)
    return false if unfollowed_in_last_hour.count >= 50 || unfollowed_in_last_day.count >= 900
    true
  end

  def began_following_users
    twitter_follows.first.created_at.to_date rescue nil
  end

  def hashtags
    twitter_follow_preference.hashtags.tr('#','').tr(' ','').split(',') rescue []
  end

  def self.send_reauth_email
    users = [User.wants_twitter_follow, User.wants_twitter_unfollow]
      .flatten.uniq(&:email)
    users.each do |user|
      next unless user.email.present?
      UserMailer.reauthentication_notification(user).deliver_later
    end
  end

  private

  def init_follow_prefs
    TwitterFollowPreference.create(
      user: self,
      rate_limit_until: Time.zone.now
    )
  end

end
