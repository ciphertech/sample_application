namespace :db do
  desc "Erase and fill database"
  task :populate => :environment do
    require 'populator'
    require 'faker'
    
    #[User,UserDetail,Discussion,UserDiscussion,Comment, Album, Picture,PhotoComment].each(&:delete_all)
    
    User.populate 10000 do |user|
      user.username = Faker::Name.first_name
      user.encrypted_password = "b0e1d0d604a188cb8f9d32b93405f29ad5914a8b"
      user.system_role = 10
      user.account_status = "active"
      user.email = Faker::Internet.email
      UserDetail.populate 1 do |user_detail|
        user_detail.work_info = Populator.words(4..10)
        user_detail.education = Populator.words(4..10)
        user_detail.age = 25
        user_detail.interest_internet = Populator.words(4..10)
        user_detail.about_me = Populator.words(4..10)
        user_detail.user_id = user.id
      end

      Album.populate 5 do |album|
          album.name = Populator.words(1..2)
          album.user_id = user.id
          album.share_type = 0
          Picture.populate 5 do |pic|
              pic.album_id = album.id
              pic.share_type = 0
              pic.photo_detail = Populator.words(1..5)
              pic.photo_file_name = "medium_GOOGLE-articleInline-v2.jpg"
              pic.photo_content_type = "image/jpeg"
              pic.updated_at = Populator.value_in_range(2.years.ago..Time.now)
              pic.created_at = Populator.value_in_range(2.years.ago..Time.now)
              PhotoComment.populate 5 do |com|
                com.comment =  Populator.words(1..10)
                com.user_id = user.id
                com.discussable_id = pic.id
                com.discussable_type = "Picture"
                com.updated_at = Populator.value_in_range(2.years.ago..Time.now)
                com.created_at = Populator.value_in_range(2.years.ago..Time.now)
              end
          end
      end

      Discussion.populate 10 do |discussion|
        discussion.url = Faker::Internet.url
        discussion.title = Populator.words(1..4)
        discussion.updated_at = Populator.value_in_range(2.years.ago..Time.now)
        discussion.created_at = Populator.value_in_range(2.years.ago..Time.now)
        UserDiscussion.populate 1 do |u_d|
          u_d.user_id = user.id
          u_d.discussion_id = discussion.id
          u_d.created_at = Populator.value_in_range(2.years.ago..Time.now)
          u_d.updated_at = Populator.value_in_range(2.years.ago..Time.now)
        end
        Comment.populate 5 do |com|
          com.comment = Populator.words(4..10)
          com.user_id = user.id
          com.discussion_id = discussion.id
          com.updated_at = Populator.value_in_range(2.years.ago..Time.now)
          com.created_at = Populator.value_in_range(2.years.ago..Time.now)
        end
      end

    end
  end
end
