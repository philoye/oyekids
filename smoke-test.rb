# require 'rubygems'
# require 'smoke'
# 
# Smoke.yql(:flickr) do
#   prepare do
#     select :all
#     from 'flickr.photos.search'
#     where :user_id, flickr_user_id
#   end
# end
# 
# photos1 = Smoke[:flickr].flickr_user_id('12021774@N05').output
# puts photos1.first[:query][:uri]
# photos2 = Smoke[:flickr].flickr_user_id('30853535@N00').output
# puts photos2.first[:query][:uri]

require 'rubygems'
require 'smoke'
require 'pp'

Smoke.yql(:flickr_photo_comments) do
  use 'http://github.com/philoye/yqlplayground/raw/master/flickr.photos.comments.getList.xml'
  select :all
  from 'flickr.photos.comments.getList'
  where :photo_id, "4296997958"
end


comments = Smoke[:flickr_photo_comments]
pp comments
comments = comments.output
pp comments

# http://query.yahooapis.com/v1/public/yql?q=use%20"http://github.com/philoye/yqlplayground/raw/master/flickr.photos.comments.getList.xml";%20select%20*%20from%20flickr.photos.comments.getList%20where%20photo_id%3D109722179&format=xml
# http://query.yahooapis.com/v1/public/yql?env=http://github.com/philoye/yqlplayground/raw/master/flickr.photos.comments.getList.xml&q=SELECT%20*%20FROM%20flickr.photos.comments.getList%20WHERE%20photo_id%20=%20'4296997958'&format=json