require 'spec_helper'

describe Picture do
  fixtures :pictures, :albums,:users, :photo_comments, :ratings, :rates
  before(:each) do
    @picture = Picture.new(:id=>1,:photo_detail=>"somedetails",:site_name=>"somesiteurl",:share_type=>1,:album_id=>1)
  end
  it "should upload the image by url" do
    Picture.count.should eql(6)
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo17labeled_256x256.jpg"
    @picture.upload_image(image_url)
    Picture.count.should eql(7)
  end

  it "should return no. of likes" do
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo17labeled_256x256.jpg"
    @picture.upload_image(image_url)
    @picture.like_count.should eql(0)
    Like.create(:likable_id=>@picture.id,:likable_type=>"Picture",:user_id=>1)
    @picture.like_count.should eql(1)
  end

  it "should return true if picture is liked by user" do
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo17labeled_256x256.jpg"
    @picture.upload_image(image_url)
    user = users(:one)
    @picture.is_liked_by(user.id).should be_false
    Like.create(:likable_id=>@picture.id,:likable_type=>"Picture",:user_id=>user.id)
    @picture.is_liked_by(user.id).should be_true
  end

  it "should return the users who liked the picture" do
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo17labeled_256x256.jpg"
    @picture.upload_image(image_url)
    user1 = users(:one)
    @picture.likers.count.should eql(0)
    Like.create(:likable_id=>@picture.id,:likable_type=>"Picture",:user_id=>user1.id)
    @picture.likers.count.should eql(1)
    user2 = users(:two)
    Like.create(:likable_id=>@picture.id,:likable_type=>"Picture",:user_id=>user2.id)
    @picture.likers.count.should eql(2)
  end

  it "should return the no. of comments on picture" do
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo17labeled_256x256.jpg"
    @picture.upload_image(image_url)
    user1 = users(:one)
    @picture.comment_count.should eql(0)
    PhotoComment.create(:discussable_id=>@picture.id,:discussable_type=>"Picture",:user_id=>user1.id,:comment=>"HEllo")
    @picture.comment_count.should eql(1)
    user2 = users(:two)
    PhotoComment.create(:discussable_id=>@picture.id,:discussable_type=>"Picture",:user_id=>user2.id,:comment=>"HEllo")
    @picture.comment_count.should eql(2)
  end

  it "should return the no. of comments on picture" do
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo17labeled_256x256.jpg"
    @picture.upload_image(image_url)
    PhotoComment.create(:discussable_id=>@picture.id,:discussable_type=>"Picture",:user_id=>1,:comment=>"HEllo")
    @picture.top_five_comments.count.should eql(1)
    PhotoComment.create(:discussable_id=>@picture.id,:discussable_type=>"Picture",:user_id=>1,:comment=>"HEllo")
    PhotoComment.create(:discussable_id=>@picture.id,:discussable_type=>"Picture",:user_id=>1,:comment=>"HEllo")
    PhotoComment.create(:discussable_id=>@picture.id,:discussable_type=>"Picture",:user_id=>1,:comment=>"HEllo")
    PhotoComment.create(:discussable_id=>@picture.id,:discussable_type=>"Picture",:user_id=>1,:comment=>"HEllo")
    PhotoComment.create(:discussable_id=>@picture.id,:discussable_type=>"Picture",:user_id=>1,:comment=>"HEllo")
    @picture.top_five_comments.count.should eql(5)
  end

  it "should return the no. raters to the picture" do
    @picture1 = pictures(:one)
    @picture1.votes.should eql(2)
    @picture2 = pictures(:two)
    @picture2.votes.should eql(1)
  end

  it "should return average_ratings to the picture" do
    @picture1 = pictures(:one)
    @picture1.average_ratings.should eql("4.5")
    @picture2 = pictures(:two)
    @picture2.average_ratings.should eql("6.0")
  end

  it "should return the users who rated the picture" do
    @picture1 = pictures(:one)
    #@user = User.create(:email=>'active@b.com', :encrypted_password => 'some_passowrd', :username=>"activeusername")
    #Rating.create(:rateable_id=>@picture.id,:rateable_type=>"Picture",:user_id=>@user.id,:rate_id=>2)
    @picture1.raters.count.should eql(2)
    @picture2 = pictures(:two)
    @picture2.raters.count.should eql(1)
  end

  it "should not upload the image by invalid url" do
    Picture.count.should eql(6)
    image_url = "http://www.nasa.gov/images/content/369242main_lroc_apollo1bele_256x256.jpg"
    @picture.upload_image(image_url)
    Picture.count.should eql(6)
  end
  
end
