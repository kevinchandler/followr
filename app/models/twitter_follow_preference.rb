class TwitterFollowPreference < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user
  validates :unfollow_after, inclusion: { in: [1, 2] }

  def rate_limited?
    rate_limit_until && rate_limit_until > Time.zone.now
  end

  def want_mass_follow?
    mass_follow
  end
end
