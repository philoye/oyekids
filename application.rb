require 'sinatra' 
require 'haml'
require 'active_support'
require 'ostruct'
require 'smoke'
require 'pp'

module CrossTheStreams
  class Application < Sinatra::Base

    configure do
      set :logging, true
      set :haml, {:format => :html4}
      set :public, File.join(File.dirname(__FILE__),'public')
      set :views, File.join(File.dirname(__FILE__),'views')
      set :static, true
      
      Dir.glob('lib/*.rb') do |filename|
        require filename
      end
    end

    before do
      domain_array = request.host.split(".")
      if domain_array.first == "www"
        domain_array.delete_at(0)
      end
      @domain_root = domain_array.first
      if @domain_root == "localhost" then @domain_root = "simonoye" end
      @site_config = OpenStruct.new(YAML.load_file("config/#{@domain_root}.yml"))
      cache_long
    end

    get '/test' do
      $app_config.flickr_api_key
    end

    get '/' do 
      @river = []
      @site_config.twitter_sources.each do |source|
        @river = @river + Smoke[:twitter].username(source['username']).include_text(source['include']).output
      end
      @site_config.flickr_sources.each do |source|
        @river = @river + Smoke[:flickr].flickr_user_id(source['nsid']).flickr_tags(source['tags']).output
      end
      @river = sort_and_group(@river,@site_config.group_stream_by,@site_config.birthdate)
      @page_title = ""
      haml :index
    end
    get '/tweets/?' do
      @river = []
      @site_config.twitter_sources.each do |source|
        @river = @river + Smoke[:twitter].username(source['username']).include_text(source['include']).output
      end
      @river = sort_and_group(@river,@site_config.group_stream_by,@site_config.birthdate)
      @page_title = "Words by "
      haml :index
    end
    get '/photos/?' do
      @river = []
      @site_config.flickr_sources.each do |source|
        @river = @river + Smoke[:flickr].flickr_user_id(source['nsid']).flickr_tags(source['tags']).output
      end
      @river = sort_and_group(@river,@site_config.group_stream_by,@site_config.birthdate)
      @page_title = "Photos of "
      haml :index
    end

    get '/photos/:user/?' do
      redirect '/photos'
    end
    get '/photos/:user/:id/?' do
      @photo = Smoke[:flickr_photo_info].photo_id(params[:id]).output.first
      @sizes = Smoke[:flickr_photo_sizes].photo_id(params[:id]).output
      @comments = Smoke[:flickr_photo_comments].photo_id(params[:id]).output
      haml :photo
    end

    not_found do
      haml :not_found
    end
    error do
      @error = request.env['sinatra.error'].to_s
      haml :error
    end unless Sinatra::Application.environment == :development
    
  end
end