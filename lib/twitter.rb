require 'rubygems'
require 'httparty'

class Twitter
  include HTTParty
  base_uri 'twitter.com'

  def initialize(u, p)
    @auth = {:username => u, :password => p}
  end
    
  def timeline(which=:user, options={})
   options.merge!({ :basic_auth => @auth} )
   self.class.get("/statuses/#{which}_timeline.json", options)
  end

  def filtered_tweets(whitelist=nil,blacklist=nil)
    timeline.reject do |tweet|
      tweet['text'][0] == 64 # or tweet['text'].downcase.include? "definitely"
    end
  end
  
end