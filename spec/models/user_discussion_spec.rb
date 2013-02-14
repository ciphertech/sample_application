require 'spec_helper'

describe UserDiscussion do
  fixtures :users, :follower_followings
  before(:each) do
    @user_discusison = UserDiscussion.new(:id=>1,:discussion_id=>1)
  end

  it "should send mail after user discussion creation" do
    user = users(:one)
    @discussion = Discussion.create(:discussion=>"hellow",:discussion_type=>"Comment/Question",:share_type=>"groups")
    @user_discusison.user_id = user.id
    @user_discusison.discussion_id = @discussion.id
    @user_discusison.save
  end
  
end
