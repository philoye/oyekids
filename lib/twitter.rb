require 'rubygems'
require 'httparty'
require 'lib/icebox'

class Twitter
  include HTTParty
  include Icebox
  base_uri 'twitter.com'

  def initialize(u)
    @user = u
  end
    
  def show(id)
    tweet = self.class.get_cached("/statuses/show/#{id}.json")
    users = $config['services']['twitter']['users']
    whitelist = []
    users.each do |user|
      whitelist << user['username']
    end
    if whitelist.include? tweet['user']['screen_name'] then tweet end
  end
    
  def timeline(username=:username, options={})
    self.class.get_cached("/statuses/user_timeline/#{@user}.json", options)
  end

  def filter_tweets(whitelist,blacklist)
    t = timeline
    # t = timeline.reject { |tweet| tweet['text'][0] == 64 }
    if whitelist
      t.reject! do |tweet|
        isuck = tweet['text'].downcase.include? whitelist
        !isuck
      end
    end
    if blacklist
      t.reject! do |tweet|
        !(tweet['text'].downcase.include? blacklist)
      end
    end
    return t
  end
  
end