Smoke.configure do |c|
  c[:cache][:enabled] = true
  c[:cache][:store] = :memory
  c[:cache][:expire_in] = 1800
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
      rename :created_at => :created
      transform :created do |datestring|
        DateTime.parse(datestring).new_offset(Rational(10,24)).to_s # Convert from UTC to Local
      end
      sort :created
      reverse
    end
  end
end

Smoke.yql(:flickr) do
  prepare do
    select :all
    from 'flickr.photos.search(0,500)'
    where :user_id, flickr_user_id
    where :tags, flickr_tags
    where :extras, 'date_taken, last_update, date_upload, owner_name, media'
    path :query, :results, :photo

    emit do
      insert :source, "flickr"
      insert :user, flickr_user_name
      rename :datetaken => :created
      transform :created do |datestring|
        DateTime.parse(datestring).to_s
      end
      sort :created
      reverse
    end
  end
end

Smoke.join(:twitter, :flickr) do
  name :stream
  emit do
    sort :created
    reverse
  end
end

Smoke.yql(:flickr_photo_info) do
  prepare do
    select :all
    from 'flickr.photos.info'
    where :photo_id, photo_id
    path :query, :results, :photo
  end
end

Smoke.yql(:flickr_photo_sizes) do
  prepare do
    select :all
    from 'flickr.photos.sizes'
    where :photo_id, photo_id
    path :query, :results, :size
  end
end

# TODO: Need to create an open data table for this.
Smoke.yql(:flickr_photo_comments) do
  prepare do
    select :all
    from 'flickr.photos.comments.getlist'
    where :photo_id, photo_id
    path :query, :results, :comments
  end
end