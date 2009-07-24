require 'rubygems'
require 'httparty'

class Twitter
  include HTTParty
  base_uri 'twitter.com'

  def initialize(u, p)
    @auth = {:username => u, :password => p}
  end
    
  def show(id)
    tweet = self.class.get("/statuses/show/#{id}.json", :basic_auth => @auth)
    users = $config['services']['twitter']['users']
    whitelist = []
    users.each do |user|
      whitelist << user['username']
    end
    if whitelist.include? tweet['user']['screen_name'] then tweet end
  end
    
  def timeline(which=:user, options={})
    options.merge!({ :basic_auth => @auth} )
    self.class.get("/statuses/#{which}_timeline.json", options)
  end

  def filter_tweets(whitelist,blacklist)
    t = timeline.reject { |tweet| tweet['text'][0] == 64 }
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