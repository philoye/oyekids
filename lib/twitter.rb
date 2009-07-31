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
    
  def timeline(user=:username, options={})
    options.merge!({ :count => "200" })
    if @cache
      self.class.get_cached("/statuses/user_timeline/#{@user}.json", :query => options)
    else
      self.class.get("/statuses/user_timeline/#{@user}.json", :query => options)
    end
  end

end