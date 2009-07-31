require 'rubygems' 
require 'sinatra' 
require 'haml'
require 'pp'
require 'active_support'

module CrossTheStreams
  class Application < Sinatra::Base

    configure do
      $config = YAML.load_file('config/application.yml')
      $flickr_api_key = $config['flickr_api_key']

      set :haml, {:format => :html4}
      set :public, File.join(File.dirname(__FILE__),'public')
      set :views, File.join(File.dirname(__FILE__),'views')
      set :static, true

      Dir.glob('lib/*.rb') do |filename|
        require filename
      end
    end

    before do
      domain_root = Rack::Request.new(env).host.split('.')[0]
      config = YAML.load_file("config/#{domain_root}.yml")

      @site_slug       = config['siteslug']
      @site_name       = config['name']
      @avatar          = config['avatar']
      @about_text      = config['about_text']
      @birthdate       = config['birthdate']
      @group_stream_by = config['group_stream_by']
      @twitter_feeds   = config['services']['twitter']['users']
      @flickr_feeds    = config['services']['flickr']['users']
    end

    get '/' do 
      tweets = gather_all_tweets(false)
      photos = gather_all_photos()
      @river = sort_and_group(tweets + photos)
      haml :index
    end
    get '/refresh' do # hit this to bust the cache and refresh all apis.
      tweets = gather_all_tweets(false)
      photos = gather_all_photos(false)
      "Success"
    end
    get '/tweets/?' do
      @river = sort_and_group(gather_all_tweets(false))
      haml :index
    end
    get '/photos/?' do
      @river = sort_and_group(gather_all_photos())
      haml :index
    end

    get '/photos/:user/?' do
      redirect '/photos'
    end
    get '/photos/:user/:id/?' do
      nsid = nsid_from_user(params[:user])
      @photo = Flickr.new(nsid).photo(params[:id])
      @sizes = Flickr.new(nsid).photo_sizes(params[:id])
      @comments = Flickr.new(nsid).photo_comments(params[:id])
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