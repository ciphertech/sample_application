require 'spec_helper'

describe DiscussionGroup do
  fixtures :users
  before(:each) do
    @group_discussion = DiscussionGroup.new(:name=> 'My Groups', :user_id=> 2, :description => "This is test group" )
  end


  it "should be invalid without a group name" do
    @group_discussion.name = nil
    @group_discussion.should_not be_valid
    @group_discussion.errors[:name].should include("Group name can't be blank.")
    @group_discussion.name = "My Pics"
    @group_discussion.should be_valid
  end

  it "should be invalid with a group name more than 20" do
    @group_discussion.name = "a"*21
    @group_discussion.should_not be_valid
    @group_discussion.errors[:name].should include("is too long (maximum is 20 characters)")
    @group_discussion.name = "a"*20
    @group_discussion.should be_valid
  end

  it "should be invalid without a group description" do
    @group_discussion.description = nil
    @group_discussion.should_not be_valid
    @group_discussion.description = "This is test group description"
    @group_discussion.should be_valid
  end

  it "should be invalid with a group description" do
    @group_discussion.description = "a"*1001
    @group_discussion.should_not be_valid
    @group_discussion.description = "a"*1000
    @group_discussion.should be_valid
  end

  it "should return all discussions in discussion group" do
    @group_discussion.save
    @group_discussion.all_discussions.count.should eql(0)
    @discussion = Discussion.create(:discussion=>"hellow",:discussion_type=>"Comment/Question",:share_type=>"groups")
    @dgd = DiscussionGroupDiscussion.create(:discussion_group_id=>@group_discussion.id,:discussion_id=>@discussion.id)
    @group_discussion.all_discussions.count.should eql(1)
  end

  it "should return all discussions in discussion group" do
    @group_discussion.save
    @group_discussion.all_group_discussions(1).count.should eql(0)
    @discussion = Discussion.create(:discussion=>"hellow",:discussion_type=>"Comment/Question",:share_type=>"groups")
    @dgd = DiscussionGroupDiscussion.create(:discussion_group_id=>@group_discussion.id,:discussion_id=>@discussion.id)
    @group_discussion.all_group_discussions(1).count.should eql(1)
  end

  it "should return users in discussion group" do
    @group_discussion.save
    @group_discussion.group_users.count.should eql(0)
    user1 = users(:one)
    @dgu = DiscussionGroupUser.create(:discussion_group_id=>@group_discussion.id,:user_id=>user1.id,:is_member=>false)
    @group_discussion.group_users.count.should eql(0)
    user2 = users(:two)
    @dgu = DiscussionGroupUser.create(:discussion_group_id=>@group_discussion.id,:user_id=>user2.id,:is_member=>true)
    @group_discussion.group_users.count.should eql(1)
  end

end
