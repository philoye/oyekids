require 'rubygems' 
require 'sinatra' 
require 'haml'
require 'pp'
require 'active_support'

module CrossTheStreams
  class Application < Sinatra::Base

    configure do
      $config = YAML.load_file('config/application.yml')

      set :haml, {:format => :html4}
      set :public, File.join(File.dirname(__FILE__),'public')
      set :views, File.join(File.dirname(__FILE__),'views')
      set :static, true

      Dir.glob('lib/*.rb') do |filename|
        require filename
      end
    end

    get '/' do 
      tweets = gather_all_tweets($config['services']['twitter']['users'])
      photos = gather_all_photos($config['services']['flickr']['users'])
      @river = tweets + photos
      @river = @river.sort_by { |drop| drop['created'] }.reverse!
      @river_by_month = @river.group_by { |drop| drop['age_month'] }
      haml :index
    end

    get '/photos/?' do
      @river = gather_all_photos($config['services']['flickr']['users'])
      @river = @river.sort_by { |drop| drop['created'] }.reverse!
      @river_by_month = @river.group_by { |drop| drop['age_month'] }
      haml :index
    end
    get '/photos/:id/?' do
      
    end

    get '/tweets/?' do
      @river = gather_all_tweets($config['services']['twitter']['users'])
      @river = @river.sort_by { |drop| drop['created'] }.reverse!
      @river_by_month = @river.group_by { |drop| drop['age_month'] }
      haml :index
    end
    get '/tweets/:id/?' do
      allowed_users = $config['services']['twitter']['users']
      @tweet = Twitter.new(allowed_users[0]['username'], allowed_users[0]['password']).show(params[:id])
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