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

  def filter_replies()
    timeline.reject { |tweet| tweet['text'][0] == 64 }
  end
  def filter_tweets(text)
    timeline.reject { |tweet| tweet['text'].downcase.include? text }
  end
  
end