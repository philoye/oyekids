require 'rubygems'
require 'httparty'
require 'lib/icebox'

class Flickr
	include HTTParty
  include Icebox
  base_uri 'http://api.flickr.com/services/rest'
  default_params :api_key => $config['services']['flickr']['api_key'], :output => 'json'

  def initialize(nsid)
    self.class.default_params :user_id => nsid
  end

  def photos(options={})
    options.merge!({ :method => 'flickr.photos.search', :per_page => '500', :page => '1', :extras => 'date_taken, last_update, date_upload, owner_name, media'})
    self.class.get_cached('',:query => options)['rsp']['photos']['photo']
  end
  
  def photo(id)
    self.class.get_cached('',:query => {:method => 'flickr.photos.getInfo', :photo_id => id})['rsp']['photo']
  end
  
  def photo_comments(id)
    self.class.get_cached('',:query => {:method => 'flickr.photos.comments.getList', :photo_id => id})['rsp']['comments']
  end
  
end