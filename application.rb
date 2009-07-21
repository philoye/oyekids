require 'rubygems' 
require 'sinatra' 
require 'haml'

module CrossTheStreams
  class Application < Sinatra::Base

    configure do
      $config = YAML.load_file('config/application.yml')

      set :haml, {:format => :html4}
      set :static, true

      Dir.glob('lib/*.rb') do |filename|
        require filename
      end
    end

    get '/' do 
      t = $config['services']['twitter']['users'][0]
      @tweets = Twitter.new(t['username'], t['password']).filtered_tweets('felix, felixoye')

      f = $config['services']['flickr']
      @photos = Flickr.new(f['users'][0]['nsid']).photos(:tags => "felix, felixoye")

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
      content_type 'text/html'
      haml :not_found
    end
    error do
      @error = request.env['sinatra.error'].to_s
      content_type 'text/html'
      haml :error
    end unless Sinatra::Application.environment == :development
    
  end
end