require 'rubygems'
require 'httparty'

class Flickr
	include HTTParty
  base_uri 'http://api.flickr.com/services/rest'
  default_params :api_key => $config['services']['flickr']['api_key'], :output => 'json'

  def initialize(nsid)
    self.class.default_params :user_id => nsid
  end

  def photos(options={})
    options.merge!({ :method => 'flickr.photos.search', :per_page => '500', :page => '1', :extras => 'date_taken, last_update, date_upload,owner_name'})
    self.class.get('',:query => options)['rsp']['photos']['photo']
  end
  
  def photo(id)
    self.class.get('',:query => {:method => 'flickr.photos.getInfo', :photo_id => id})['rsp']['photo']
  end
  
end