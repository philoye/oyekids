require 'httparty'
require 'lib/icebox'

class Flickr
	include HTTParty
  include Icebox
  base_uri 'http://api.flickr.com/services/rest'
  default_params :api_key => $flickr_api_key, :output => 'json'

  def initialize(nsid,cache=true)
    @nsid = nsid
    @cache = cache
  end

  def photo_comments(id)
    self.class.get_cached('',:query => {:user_id=>@nsid, :method => 'flickr.photos.comments.getList', :photo_id => id})['rsp']['comments']
  end
  
end