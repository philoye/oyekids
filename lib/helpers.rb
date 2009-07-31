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
  %(<img src="#{flickr_src(photo, "s")}" width="75" height="75" title="#{photo['title']}">)
end
def flickr_embed_code(video,desired_width)
  width = video['width']
  height = video['height']
  if (desired_width < width)
    height = (desired_width.to_i * height.to_i / width.to_i).to_s
    width = desired_width
  end
  %(<object type="application/x-shockwave-flash" width="#{width}" height="#{height}" data="#{video['source']}"  classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"> <param name="flashvars" value="flickr_show_info_box=false"></param> <param name="movie" value="#{video['source']}"></param><param name="bgcolor" value="#000000"></param><param name="allowFullScreen" value="true"></param><embed type="application/x-shockwave-flash" src="#{video['source']}" bgcolor="#000000" allowfullscreen="true" flashvars="flickr_show_info_box=false" height="#{height}" width="#{width}"></embed></object>)
end
def photo_path(photo)
  user = user_from_nsid(photo['owner'])
  "/photos/#{user}/#{photo['id']}"
end
def user_from_nsid(text)
  username = @flickr_feeds.each do |user|
    if text = user['nsid']
      username = user['username']
    end
    return username
  end
end
def nsid_from_user(text)
  nsid = @flickr_feeds.each do |user|
    if text = user['username']
      nsid = user['nsid']
    end
    return nsid
  end
end

def twitter_url(tweet)
  "http://twitter.com/" + tweet['user']['screen_name'] + "/status/" + tweet['id'].to_s
end
def format_tweet(text)
  text.linkify.link_mentions.link_hash_tags
end

def sort_and_group(array_of_items)
  river = array_of_items.sort_by { |drop| drop['created'] }.reverse!
  return river.group_by { |drop| drop[@group_stream_by] }
end

def gather_all_photos(cache=true)
  all_items = []
  @flickr_feeds.each do |feed|
    items = Flickr.new(feed['nsid'],cache).photos(:tags => feed['tags'])
    items.each do |item|
      harmonize_stream(item,"datetaken")
    end
    all_items = items + all_items
  end
  return all_items
end
def gather_all_tweets(cache=true)
  all_items = []
  @twitter_feeds.each do |feed|
    tweets = Twitter.new(feed['username'],cache).timeline
    items = filter_tweets(tweets,feed['include'],feed['exclude'])
    items.each do |item|
      harmonize_stream(item,"created_at")
    end
    all_items = items + all_items
  end
  return all_items
end
def filter_tweets(tweets,whitelist,blacklist)
  if whitelist
    tweets = tweets.reject do |tweet|
      !(tweet['text'].downcase.include? whitelist.downcase)
    end
  end
  if blacklist
    tweets = tweets.reject do |tweet|
      (tweet['text'].downcase.include? blacklist.downcase)
    end
  end
  return tweets
end
def harmonize_stream(item,attribute)
  bd = DateTime.parse(@birthdate.to_s)
  d  = DateTime.parse(item[attribute])
  item['age_month']  = ((d - bd) / 30.4).to_i.to_s
  item['calendar_month'] = d.strftime("%Y-%m").to_s
  item['created'] = d
  return item
end

def pretty_date(datetime_string)
  DateTime.parse(datetime_string).strftime("%e %B %y, %l:%m%p")
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
  def slugify
    self.downcase.gsub(/'/, '').gsub(/[^a-z0-9]+/, '-') do |slug|
      slug.chop! if slug.last == '-'
    end
  end
end

def pluralize(number, singular)
  case number.to_i
  when 0
    "No #{singular}s"
  when 1
    "1 #{singular}"
  else
    "#{number} #{singular}s"
  end
end