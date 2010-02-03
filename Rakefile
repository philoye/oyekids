namespace :feeds do 
  require "#{File.join(File.dirname(__FILE__),'lib','helpers.rb')}"
  require "#{File.join(File.dirname(__FILE__),'lib','stream.rb')}"

  task :refresh do
    @site_config = OpenStruct.new(YAML.load_file(File.join(File.dirname(__FILE__),"config", "oyekids.yml")))
    @river = []
    Smoke::Cache.clear!
    refresh_tweets
    refresh_photos
  end
end