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
  #TODO: remove hard coded username
  "http://www.flickr.com/photos/philoye/#{photo['id']}/"
end
def flickr_square(photo)
  %(<img src="#{flickr_src(photo, "s")}" width="75" height="75" />)
end
def photo_path(photo)
  "/photos/#{photo[:id]}"
end
