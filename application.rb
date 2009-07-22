require 'rubygems' 
require 'sinatra' 
require 'haml'
require 'pp'

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
      t = $config['services']['twitter']['users'][0]
      tweets = Twitter.new(t['username'], t['password']).filtered_tweets('felix, felixoye')
      tweets.each do |tweet|
        s = tweet['created_at']
        d = DateTime.parse(s).to_s
        tweet['created'] = d
      end

      f = $config['services']['flickr']
      photos = Flickr.new(f['users'][0]['nsid']).photos(:tags => "felix, felixoye")
      photos.each do |photo|
        s = photo['datetaken']
        d = DateTime.parse(s).to_s
        photo['created'] = d
      end
      @river = tweets + photos
      @river = @river.sort_by { |drop| drop['created'] }.reverse!
      haml :index
    end

    get '/photos/' do
      
    end
    get '/photos/:id' do
      
    end

    get '/tweets/' do

    end
    get '/tweets/:id' do

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