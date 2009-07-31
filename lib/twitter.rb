require 'rubygems'
require 'httparty'
require 'lib/icebox'

class Twitter
  include HTTParty
  include Icebox
  base_uri 'twitter.com'

  def initialize(u,cache=true)
    @user = u
    @cache = cache
  end
    
  def timeline(username=:username, options={})
    options.merge!({ :count => "200" })
    if @cache
      self.class.get_cached("/statuses/user_timeline/#{@user}.json", :query => options)
    else
      self.class.get("/statuses/user_timeline/#{@user}.json", :query => options)
    end
  end

  def filter_tweets(whitelist,blacklist)
    t = timeline
    # t = timeline.reject { |tweet| tweet['text'][0] == 64 } # Filter out replies
    if whitelist
      t.reject! do |tweet|
        !(tweet['text'].downcase.include? whitelist.downcase)
      end
    end
    if blacklist
      t.reject! do |tweet|
        (tweet['text'].downcase.include? blacklist.downcase)
      end
    end
    return t
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
    
end