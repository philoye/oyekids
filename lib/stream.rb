require 'smoke'

Smoke.configure do |c|
  c[:cache][:enabled] = true
  c[:cache][:store] = :memory
  c[:cache][:expire_in] = 600
end

Smoke.data(:twitter) do
  prepare do
    url "http://twitter.com/statuses/user_timeline/#{username}.xml?count=200"
    path :statuses

    emit do
      keep :text, /#{include_text}/i
      insert :source, "twitter"
      transform :user do |user|
        user[:screen_name]
      end
      transform :created_at do |datestring|
        DateTime.parse(datestring).new_offset(Rational(10,24)).to_s # Convert from UTC to Local
      end
    end
  end
end

# Smoke.yql(:flickr) do
#   prepare do
#     select :all
#     from 'flickr.photos.search(0,500)'
#     where :user_id, flickr_user_id
#     where :tags, flickr_tags
#     where :extras, 'date_taken, last_update, date_upload, owner_name, media'
#     path :query, :results, :photo
# 
#     emit do
#       insert :source, "flickr"
#       insert :user, flickr_user_name
#       rename :datetaken => :created_at
#       transform :created_at do |datestring|
#         DateTime.parse(datestring).to_s
#       end
#     end
#   end
# end

Smoke.data(:flickr) do
  prepare do
    url "http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=#{ENV['OYEKIDS_FLICKR_API_KEY']}&user_id=#{flickr_user_id}&extras=date_taken%2Clast_update%2Cdate_upload%2C+owner_name%2C+media&tags=#{flickr_tags}&per_page=500"
    path :rsp, :photos, :photo
    
    emit do
      insert :source, "flickr"
      rename :ownername => :user
      rename :datetaken => :created_at
      transform :created_at do |datestring|
        DateTime.parse(datestring).to_s
      end
    end
  end
end

# Smoke.yql(:flickr_photo_info) do
#   prepare do
#     select :all
#     from 'flickr.photos.info'
#     where :photo_id, photo_id
#     path :query, :results, :photo
#   end
# end

Smoke.data(:flickr_photo_info) do
  prepare do
    url "http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=#{ENV['OYEKIDS_FLICKR_API_KEY']}&photo_id=#{photo_id}"
    path :rsp, :photo
  end
end

# Smoke.yql(:flickr_photo_sizes) do
#   prepare do
#     select :all
#     from 'flickr.photos.sizes'
#     where :photo_id, photo_id
#     path :query, :results, :size
#   end
# end

Smoke.data(:flickr_photo_sizes) do
  prepare do
    url "http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=#{ENV['OYEKIDS_FLICKR_API_KEY']}&photo_id=#{photo_id}"
    path :rsp, :sizes, :size
  end
end

# Sample YQL query
# use "http://github.com/philoye/yqlplayground/raw/master/flickr.photos.comments.getList.xml"; select * from flickr.photos.comments.getList where photo_id=4296997958
# Smoke.yql(:flickr_photo_comments) do
#     use "http://github.com/philoye/yqlplayground/raw/master/flickr.photos.comments.getList.xml"
#     select :all
#     from 'flickr.photos.comments.getList'
#     where :photo_id, '4296997958'
# end

Smoke.data(:flickr_photo_comments) do
  prepare do
    url "http://api.flickr.com/services/rest/?method=flickr.photos.comments.getList&api_key=#{ENV['OYEKIDS_FLICKR_API_KEY']}&photo_id=#{photo_id}"
    path :rsp, :comments
  end
end