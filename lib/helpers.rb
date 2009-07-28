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
  "http://www.flickr.com/photos/#{photo['owner']['username']}/#{photo['id']}/"
end
def flickr_square(photo)
  %(<img src="#{flickr_src(photo, "s")}" width="75" height="75" title="#{photo['title']}" />)
end
def photo_path(photo)
  user = user_from_nsid(photo['owner'])
  "/photos/#{user}/#{photo['id']}"
end

def twitter_url(tweet)
  "http://twitter.com/" + tweet['user']['screen_name'] + "/status/" + tweet['id'].to_s
end
def format_tweet(text)
  text.linkify.link_mentions.link_hash_tags
end
def user_from_nsid(text)
  users = $config['services']['flickr']['users']
  username = users.each do |user|
    if text = user['nsid']
      username = user['username']
    end
    return username
  end
end
def nsid_from_user(text)
  users = $config['services']['flickr']['users']
  nsid = users.each do |user|
    if text = user['username']
      nsid = user['nsid']
    end
    return nsid
  end
end

def pretty_date(datetime_string)
  dt = DateTime.parse(datetime_string)
  dt.strftime("%d %B %y, %l:%m%p")
end

def gather_all_photos(feeds)
  all_items = []
  feeds.each do |feed|
    items = Flickr.new(feed['nsid']).photos(:tags => feed['tags'])
    items.each do |photo|
      bd = DateTime.parse($config['birthdate'].to_s)
      d = DateTime.parse(photo['datetaken'])
      photo['age_month']  = ((d - bd) / 30.4).to_i.to_s
      photo['created'] = d
    end
    all_items = items + all_items
  end
  all_items
end
def gather_all_tweets(feeds)
  all_items = []
  feeds.each do |feed|
    items = Twitter.new(feed['username']).filter_tweets(feed['include'],feed['reject'])
    items.each do |tweet|
      bd = DateTime.parse($config['birthdate'].to_s)
      d = DateTime.parse(tweet['created_at'])
      tweet['age_month']  = ((d - bd)/30).to_i.to_s
      tweet['created'] = d
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
