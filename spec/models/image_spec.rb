require 'spec_helper'

describe Image do
  fixtures :images, :users, :photo_comments, :ratings, :rates
  before(:each) do
    @image = Image.new(:id=>1,:details=>"somedetails",:site_url=>"somesiteurl",:imageable_id=>1,:imageable_type=>"DiscussionGroup",:user_id=>1)
  end
  it "should upload the image by url" do
    Image.count.should eql(6)
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo17labeled_256x256.jpg"
    @image.upload_image(image_url)
    @image.save
    Image.count.should eql(7)
  end

  it "should return no. of likes" do
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo17labeled_256x256.jpg"
    @image.upload_image(image_url)
    @image.save
    @image.like_count.should eql(0)
    Like.create(:likable_id=>@image.id,:likable_type=>"Image",:user_id=>1)
    @image.like_count.should eql(1)
  end

  it "should return true if Image is liked by user" do
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo17labeled_256x256.jpg"
    @image.upload_image(image_url)
    @image.save
    user = users(:one)
    @image.is_liked_by(user.id).should be_false
    Like.create(:likable_id=>@image.id,:likable_type=>"Image",:user_id=>user.id)
    @image.is_liked_by(user.id).should be_true
  end

  it "should return the users who liked the Image" do
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo17labeled_256x256.jpg"
    @image.upload_image(image_url)
    @image.save
    user1 = users(:one)
    @image.likers.count.should eql(0)
    Like.create(:likable_id=>@image.id,:likable_type=>"Image",:user_id=>user1.id)
    @image.likers.count.should eql(1)
    user2 = users(:two)
    Like.create(:likable_id=>@image.id,:likable_type=>"Image",:user_id=>user2.id)
    @image.likers.count.should eql(2)
  end

  it "should return the no. of comments on Image" do
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo17labeled_256x256.jpg"
    @image.upload_image(image_url)
    @image.save
    user1 = users(:one)
    @image.comment_count.should eql(0)
    PhotoComment.create(:discussable_id=>@image.id,:discussable_type=>"Image",:user_id=>user1.id,:comment=>"HEllo")
    @image.comment_count.should eql(1)
    user2 = users(:two)
    PhotoComment.create(:discussable_id=>@image.id,:discussable_type=>"Image",:user_id=>user2.id,:comment=>"HEllo")
    @image.comment_count.should eql(2)
  end

  it "should return the no. of comments on Image" do
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo17labeled_256x256.jpg"
    @image.upload_image(image_url)
    @image.save
    PhotoComment.create(:discussable_id=>@image.id,:discussable_type=>"Image",:user_id=>1,:comment=>"HEllo")
    @image.top_five_comments.count.should eql(1)
    PhotoComment.create(:discussable_id=>@image.id,:discussable_type=>"Image",:user_id=>1,:comment=>"HEllo")
    PhotoComment.create(:discussable_id=>@image.id,:discussable_type=>"Image",:user_id=>1,:comment=>"HEllo")
    PhotoComment.create(:discussable_id=>@image.id,:discussable_type=>"Image",:user_id=>1,:comment=>"HEllo")
    PhotoComment.create(:discussable_id=>@image.id,:discussable_type=>"Image",:user_id=>1,:comment=>"HEllo")
    PhotoComment.create(:discussable_id=>@image.id,:discussable_type=>"Image",:user_id=>1,:comment=>"HEllo")
    @image.top_five_comments.count.should eql(5)
  end


  it "should not upload the image by invalid url" do
    Image.count.should eql(6)
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo1bele_256x256.jpg"
    @image.upload_image(image_url)
    @image.save
    Image.count.should eql(6)
  end

  it "should return the user who have added the photo for discussion group" do
    NonSiteUser.create(:email=>"jalendraa.bhanarkar@cipher-tech.com", :invitable_id=>1, :invitable_type=>"Group")
    @user = User.create(:username=>"jalendra",:encrypted_password=>"b0e1d0d604a188cb8f9d32b93405f29ad5914a8b",:system_role=> 10,:email=> "jalendraa.bhanarkar@cipher-tech.com")
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo17labeled_256x256.jpg"
    @image.user_id = @user.id
    @image.upload_image(image_url)
    @image.save
    @image.pic_user.should eql(@user)
  end

  it "should return the user who have added the photo for discussion" do
    NonSiteUser.create(:email=>"jalendraa.bhanarkar@cipher-tech.com", :invitable_id=>1, :invitable_type=>"Group")
    @user = User.create(:username=>"jalendra",:encrypted_password=>"b0e1d0d604a188cb8f9d32b93405f29ad5914a8b",:system_role=> 10,:email=> "jalendraa.bhanarkar@cipher-tech.com")
    @d = @user.add_discussion?({:discussion=>"woww",:discussion_type=>"Comment/Question",:share_type=>"groups"})
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo17labeled_256x256.jpg"
    @image.imageable_type = "Discussion"
    @image.imageable_id = @d.id
    @image.upload_image(image_url)
    @image.save
    @image.pic_user.should eql(@user)
  end

  it "should return the user who have added the photo for comment" do
    NonSiteUser.create(:email=>"jalendraa.bhanarkar@cipher-tech.com", :invitable_id=>1, :invitable_type=>"Group")
    @user = User.create(:username=>"jalendra",:encrypted_password=>"b0e1d0d604a188cb8f9d32b93405f29ad5914a8b",:system_role=> 10,:email=> "jalendraa.bhanarkar@cipher-tech.com")
    @d = @user.add_discussion?({:discussion=>"woww",:discussion_type=>"Comment/Question",:share_type=>"groups"})
    @c = Comment.create(:user_id=>@user.id,:discussion_id=>@d.id, :comment=>"hello",:comment_type=>"Comment/Question")
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo17labeled_256x256.jpg"
    @image.imageable_type = "Comment"
    @image.imageable_id = @c.id
    @image.upload_image(image_url)
    @image.save
    @image.pic_user.should eql(@user)
  end
  
end
