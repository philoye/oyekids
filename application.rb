require 'rubygems' 
require 'sinatra' 
require 'haml'
require 'pp'
require 'active_support'
require 'ostruct'

module CrossTheStreams
  class Application < Sinatra::Base

    configure do
      $flickr_api_key = "bffdaa9407fcf762439aedaf938e01ac"

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
      if @domain_root == "localhost" then @domain_root = "oyekids" end

      @config =  OpenStruct.new(YAML.load_file("config/#{@domain_root}.yml"))
    end

    get '/' do 
      tweets = gather_all_tweets(false) # pass "false" to turn off caching, which is fucking things up.
      photos = gather_all_photos(false)
      @river = sort_and_group(tweets + photos)
      @page_title = ""
      haml :index
    end
    get '/refresh' do # hit this to bust the cache and refresh all apis.
      tweets = gather_all_tweets(false)
      photos = gather_all_photos(false)
      "Success"
    end
    get '/tweets/?' do
      @river = sort_and_group(gather_all_tweets())
      @page_title = "Words by "
      haml :index
    end
    get '/photos/?' do
      @river = sort_and_group(gather_all_photos())
      @page_title = "Photos of "
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