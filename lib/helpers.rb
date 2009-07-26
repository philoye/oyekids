def versioned_stylesheet(stylesheet)
  __DIR__ = File.dirname(__FILE__)
  "/css/#{stylesheet}.css?" + File.mtime(File.join(__DIR__,"..", 'public', "css", "#{stylesheet}.css")).to_i.to_s
end
def versioned_javascript(js)
  __DIR__ = File.dirname(__FILE__)
  "/js/#{js}.js?" + File.mtime(File.join(__DIR__,"..", 'public', "js", "#{js}.js")).to_i.to_s
end

def partial(name)
  haml(:"_#{name}", :layout => false)
end

def flickr_src(photo, size=nil)
  "http://farm#{photo['farm']}.static.flickr.com/#{photo['server']}/#{photo['id']}_#{photo['secret']}#{size && "_#{size}"}.jpg"
end
def flickr_url(photo)
  "http://www.flickr.com/photos/#{photo['ownername']}/#{photo['id']}/"
end
def flickr_square(photo)
  %(<img src="#{flickr_src(photo, "s")}" width="75" height="75" title="#{photo['title']}" />)
end
def photo_path(photo)
  "/photos/#{photo['id']}"
end

def twitter_url(tweet)
  "http://twitter.com/" + tweet['user']['screen_name'] + "/status/" + tweet['id'].to_s
end
def format_tweet(text)
  text.linkify.link_mentions.link_hash_tags
end

def gather_all_photos(feeds)
  all_items = []
  feeds.each do |feed|
    items = Flickr.new(feed['nsid']).photos(:tags => feed['tags'])
    items.each do |photo|
      bd = DateTime.parse($config['birthdate'].to_s)
      d = DateTime.parse(photo['datetaken'])
      photo['created'] = d.to_s
      photo['age_month']  = ((d - bd) / 30.4).to_i.to_s
    end
    all_items = items + all_items
  end
  all_items
end
def gather_all_tweets(feeds)
  all_items = []
  feeds.each do |feed|
    items = Twitter.new(feed['username'], feed['password']).filter_tweets(feed['include'],feed['reject'])
    items.each do |tweet|
      bd = DateTime.parse($config['birthdate'].to_s)
      d = DateTime.parse(tweet['created_at'])
      tweet['created'] = d.to_s
      tweet['age_month']  = ((d - bd)/30).to_i.to_s
    end
    all_items = items + all_items
  end
  all_items
end


class String
  def linkify
    gsub /((https?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/, %Q{<a href="\\1">\\1</a>}
  end
  def link_mentions
    gsub(/@(\w+)/, %Q{<a href="http://twitter.com/\\1">@\\1</a>})
  end
  def link_hash_tags
    gsub(/#([^ ]*)/){ "<a class=\"hash_tag\" href=\"http://twitter.com/#search?q=%23#{$1}\">##{$1}</a>" }
  end
end
