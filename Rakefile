namespace :feeds do 
  require "#{File.join(File.dirname(__FILE__),'lib','helpers.rb')}"
  require "#{File.join(File.dirname(__FILE__),'lib','stream.rb')}"

  task :refresh do
    @site_config = OpenStruct.new(YAML.load_file(File.join(File.dirname(__FILE__),"config", "oyekids.yml")))
    
    @site_config.twitter_sources.each do |source|
      Smoke[:twitter].username(source['username']).include_text(source['include']).output
    end
    @site_config.flickr_sources.each do |source|
      Smoke[:flickr].flickr_user_id(source['nsid']).flickr_tags(source['tags']).output
    end
    "success?"
  end
end