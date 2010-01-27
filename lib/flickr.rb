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

  def photos(options={})
    options.merge!({ :user_id => @nsid, :method => 'flickr.photos.search', :per_page => '500', :page => '1', :extras => 'date_taken, last_update, date_upload, owner_name, media'})
    if @cache
      self.class.get_cached('',:query => options)['rsp']['photos']['photo']
    else
      self.class.get('',:query => options)['rsp']['photos']['photo']
    end
  end
  
  def photo(id)
    self.class.get_cached('',:query => {:user_id=>@nsid, :method => 'flickr.photos.getInfo', :photo_id => id})['rsp']['photo']
  end
  
  def photo_sizes(id)
    self.class.get_cached('',:query => {:user_id=>@nsid, :method => 'flickr.photos.getSizes', :photo_id => id})['rsp']['sizes']['size']
  end
  
  def photo_comments(id)
    self.class.get_cached('',:query => {:user_id=>@nsid, :method => 'flickr.photos.comments.getList', :photo_id => id})['rsp']['comments']
  end
  
end