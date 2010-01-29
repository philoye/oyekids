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
  "http://farm#{photo[:farm]}.static.flickr.com/#{photo[:server]}/#{photo[:id]}_#{photo[:secret]}#{size && "_#{size}"}.jpg"
end
def flickr_url(photo)
  "http://www.flickr.com/photos/#{photo[:owner][:username]}/#{photo[:id]}/"
end
def flickr_square(photo)
  %(<img src="#{flickr_src(photo, "s")}" width="75" height="75" title="#{photo[:title]}">)
end
def flickr_embed_code(video,desired_width)
  height_width = calculate_height_width(video,desired_width)
  width = height_width['width']
  height = height_width['height']
  %(<object type="application/x-shockwave-flash" width="#{width}" height="#{height}" data="#{video['source']}"  classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"> <param name="flashvars" value="flickr_show_info_box=false"></param> <param name="movie" value="#{video['source']}"></param><param name="bgcolor" value="#000000"></param><param name="allowFullScreen" value="true"></param><embed type="application/x-shockwave-flash" src="#{video['source']}" bgcolor="#000000" allowfullscreen="true" flashvars="flickr_show_info_box=false" height="#{height}" width="#{width}"></embed></object>)
end
def calculate_height_width(item,desired_width)
  width = item[:width]
  height = item[:height]
  if (desired_width.to_i < width.to_i)
    height = (desired_width.to_i * height.to_i / width.to_i).to_s
    width = desired_width
  end
  return { "height" => height, "width" => width }
end

def photo_path(photo)
  "/photos/#{photo[:user]}/#{photo[:id]}"
end
def user_from_nsid(nsid)
  username = @config.flickr_sources.each do |feed_user|
    if feed_user['nsid'] == nsid
      username = feed_user['username']
      return username
    end
  end
end
def nsid_from_user(text)
  nsid = @config.flickr_sources.each do |user|
    if text == user['username']
      nsid = user['nsid']
      return nsid
    end
  end
end

def twitter_url(tweet)
  "http://twitter.com/" + tweet[:user] + "/status/" + tweet['id'].to_s
end
def format_tweet(text)
  text.linkify.link_mentions.link_hash_tags
end

def sort_and_group(array_of_items,group_by,startdate)
  river = array_of_items.sort_by { |drop| drop[:created] }.reverse!
  return river.group_by do |drop| 
    if group_by == "age_month"
      ((DateTime.parse(drop[:created]) - DateTime.parse(startdate)) / 30.4).to_i.to_s
    else
      DateTime.parse(drop[:created]).strftime("%Y/%m").to_s
    end
  end
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

def tracking_code
  if Sinatra::Application.environment == :production
    %(
    
    <script type="text/javascript">
    var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
    document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
    </script>
    <script type="text/javascript">
    try {
    var pageTracker = _gat._getTracker("#{@config.google_analytics_id}");
    pageTracker._trackPageview();
    } catch(err) {}</script>

    <script type="text/javascript" src="http://include.reinvigorate.net/re_.js"></script>
    <script type="text/javascript">
    re_("#{@config.reinvigorate_id}");
    </script>
    
    )
  else
    "<!-- Tracking code goes here in production. -->"
  end
end
