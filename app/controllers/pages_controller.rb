class PagesController < ApplicationController
  helper :application

  def index
    redirect_to dashboard_path if current_user
  end

  def dashboard
    unless current_user || (current_user && current_user.credential.is_valid?)
      session[:user_id] = nil
      redirect_to root_path and return
    end

    if current_user.followers.present?
      @followers_count = current_user.followers.last.count
      yesterday = DateTime.now.in_time_zone.to_date - 1.day
      @yesterdays_followers = current_user.followers.select { |f| f.created_at.to_date == yesterday }.first.count rescue nil
    end
    # TODO add percent difference
    @followed_users_count = current_user.twitter_follows.count
    @began_following_users = current_user.began_following_users

    client = current_user.credential.twitter_client
    if !Rails.cache.read('twitter_trending_hashtags').present?
      Rails.cache.write('twitter_trending_hashtags', TwitterFollow.get_trending_hashtags(current_user.id))
    end
    
    trending = Rails.cache.read('twitter_trending_hashtags')
    if trending.present?
      @trending = []
      trending.each do |hashtag|
        @trending << "<a href='http://twitter.com/hashtag/#{hashtag.sub('#', '')}'>#{hashtag}</a>"
      end
      @trending = @trending.join(' | ')
    end
  end

end
