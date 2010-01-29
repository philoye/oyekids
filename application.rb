require 'sinatra' 
require 'haml'
require 'pp'
require 'active_support'
require 'ostruct'
require 'smoke'

module CrossTheStreams
  class Application < Sinatra::Base

    configure do
      $flickr_api_key = "bffdaa9407fcf762439aedaf938e01ac"

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
      if @domain_root == "localhost" then @domain_root = "oyekids" end
      @config =  OpenStruct.new(YAML.load_file("config/#{@domain_root}.yml"))
    end

    get '/' do 
      @river = Smoke[:stream].output
      @river = sort_and_group(@river,@config.group_stream_by,@config.birthdate)
      @page_title = ""
      haml :index
    end
    get '/tweets/?' do
      @river = Smoke[:twitter].output
      @river = sort_and_group(@river,@config.group_stream_by,@config.birthdate)
      @page_title = "Words by "
      haml :index
    end
    get '/photos/?' do
      @river = Smoke[:flickr].output
      @river = sort_and_group(@river,@config.group_stream_by,@config.birthdate)
      @page_title = "Photos of "
      haml :index
    end

    get '/photos/:user/?' do
      redirect '/photos'
    end
    get '/photos/:user/:id/?' do
      @photo = Smoke[:flickr_photo_info].photo_id(params[:id]).output.first
      @sizes = Smoke[:flickr_photo_sizes].photo_id(params[:id]).output
      nsid = nsid_from_user(params[:user])
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