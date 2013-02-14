require 'spec_helper'

describe Discussion do
  fixtures :users, :discussions, :ratings,:comments,:groups
  before(:each) do
    @discussion = Discussion.new(:id=>1, :discussion=>"http://www.google.com")
  end

  it "should be invalid without a discussion" do
    @discussion.discussion_type = "URL"
    @discussion.discussion = ""
    @discussion.should_not be_valid
    @discussion.errors[:discussion].should include("can't be blank.")
    @discussion.discussion = "http://www.google.com"
    @discussion.should be_valid
  end

  it "should be invalid with invalid discussion url" do
    @discussion.discussion_type = "URL"
    @discussion.discussion = "google.com"
    @discussion.discussion.should_not match(/^(ht|f)tps?:\/\/[a-z0-9-\.]+\.[a-z]{2,4}\/?([^\s<>\#%"\,\{\}\\|\\\^\[\]`]+)?$/)
    @discussion.should_not be_valid
    @discussion.errors[:discussion].should include("Please enter a valid URL.")
    @discussion.discussion = 'http://www.google.com'
    @discussion.discussion.should match(/^(ht|f)tps?:\/\/[a-z0-9-\.]+\.[a-z]{2,4}\/?([^\s<>\#%"\,\{\}\\|\\\^\[\]`]+)?$/)
    @discussion.should be_valid
  end

  it "should be invalid with discussion url of more than 300 character" do
    @discussion.discussion_type = "URL"
    @discussion.discussion = "http://www.google"+"a"*301+".com"
    @discussion.should_not be_valid
    @discussion.errors[:discussion].should include("is too long (maximum is 300 characters)")
    @discussion.discussion = 'http://www.google.com'
    @discussion.should be_valid
  end

  it "should be invalid with discussion comment/question of more than 1000 character" do
    @discussion.discussion_type = "Comment/Question"
    @discussion.discussion = "x"*1001
    @discussion.should_not be_valid
    @discussion.errors[:discussion].should include("is too long (maximum is 1000 characters)")
    @discussion.discussion = 'x'*1000
    @discussion.should be_valid
  end

  it "find the total votes for the discussion" do
    @discussion.discussion_type = "URL"
    @discussion = Discussion.create(:discussion => 'http://www.google.com')
    @rate_two = Rate.create(:score => 3)
    Rating.create(:rate_id => @rate_two.id, :rateable_id => @discussion.id, :rateable_type => 'Discussion', :user_id => 2)
    Rating.create(:rate_id => @rate_two.id, :rateable_id => @discussion.id, :rateable_type => 'Discussion', :user_id => 3) 
    @discussion.votes.should eql(2)
  end

  it "should return the title of a site if present otherwise showing url itself" do
    @discussion.discussion_type = "URL"
    @discussion = Discussion.new(:discussion => 'http://www.google.com')
    @discussion.site_title.should eql("http://www.google.com")
    @discussion = Discussion.create(:discussion => 'http://www.google.com', :title => "Google")
    @discussion.site_title.should eql("Google")
  end


  it "should add the title of a site to site url" do
    @discussion.discussion_type = "URL"
    @discussion = Discussion.create(:discussion => 'http://www.google.com',:discussion_type => "URL")
    @discussion.site_title.should eql("Google")
  end

  it "should find the array of the users ids for the discussion" do
    NonSiteUser.create(:email=>"login_user@b.com", :invitable_id=>1, :invitable_type=>"Group")
    NonSiteUser.create(:email=>"active_user@b.com", :invitable_id=>1, :invitable_type=>"Group")
    @login_user = User.create(:email=>'login_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextlogin", :system_role => User::SYSTEM_ROLE_USER)
    @other_user = User.create(:email=>'active_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextone", :system_role => User::SYSTEM_ROLE_USER)
    @discussion = Discussion.create(:discussion => 'http://www.google.com')
    UserDiscussion.create(:discussion_id => @discussion.id, :user_id => @login_user.id)
    UserDiscussion.create(:discussion_id => @discussion.id, :user_id => @other_user.id)
    @discussion = Discussion.find(@discussion)
    @discussion.user_ids.should include(@login_user.id, @other_user.id)
  end

  it "should return the no. raters to the discussions" do
    @discussion1 = discussions(:one)
    @discussion1.votes.should eql(2)
    @discussion2 = discussions(:two)
    @discussion2.votes.should eql(1)
  end

  it "should return average_ratings to the discussions" do
    @discussion1 = discussions(:one)
    @discussion1.average_ratings.should eql("4.5")
    @discussion2 = discussions(:two)
    @discussion2.average_ratings.should eql("6.0")
  end

  it "should return the users who rated the discussions" do
    @discussion1 = discussions(:one)
    @discussion1.raters.count.should eql(2)
    @discussion2 = discussions(:two)
    @discussion2.raters.count.should eql(1)
  end

  it "should return the total no. of comments on the discussions" do
    @discussion1 = discussions(:one)
    @discussion1.all_comments_count(@discussion1.id).should eql(6)
    @discussion2 = discussions(:two)
    @discussion2.all_comments_count(@discussion2.id).should eql(0)
  end

  it "should return the title of a site if present otherwise showing url itself" do
      @discussion.discussion_type = "URL"
      @discussion.discussion = 'http://www.yahoo.com/'
      @discussion.save
  end

  it "should return most popular discussions in specific time interval" do
    user = users(:two)
    user.add_discussion?({:discussion=>"yahhhhhhoooo",:discussion_type=>"Comment/Question",:share_type=>"public"})

    @d_g = DiscussionGroup.create(:name=>"My group",:user_id=>user.id,:description=>"LLLLLOL",:is_public=>true)
    Discussion.most_popular((Time.now - 30.day), Time.now,user.id,1).count.should eql(3)
    @discussion2 = discussions(:two)
    Discussion.most_popular((Time.now - 30.day), Time.now,user.id,1,false,@d_g.id).count.should eql(0)

    @d = user.add_discussion?({:discussion=>"woww",:discussion_type=>"Comment/Question",:share_type=>"groups"})
    @c = Comment.create(:user_id=>user.id,:discussion_id=>@d.id, :comment=>"hello",:comment_type=>"Comment/Question")
    @dgd = DiscussionGroupDiscussion.create(:discussion_group_id=>@d_g.id,:discussion_id=>@d.id)
    @dgu = DiscussionGroupUser.create(:user_id=>user.id, :discussion_group_id=>@d_g.id)
    Discussion.most_popular((Time.now - 30.day), Time.now,user.id,1,false,@d_g.id).count.should eql(1)
    user = users(:one)
    Discussion.most_popular((Time.now - 30.day), Time.now,user.id,1).count.should eql(4)
  end

  it "should return true or false depending on the discussions can or can.t be deleted" do
    @discussion1 = discussions(:one)
    @user = User.create(:username=>"admin123",:encrypted_password=>"b0e1d0d604a188cb8f9d32b93405f29ad5914a8b",:system_role=> 90,:email=> "jalendraa.bhanarkar@cipher-tech.com")
    @discussion1.is_deletable?(@user).should be_true
    user = users(:one)
    @discussion2 = discussions(:two)
    @u_d = UserDiscussion.create(:user_id=>user.id,:discussion_id=>@discussion2.id)
    @discussion2.is_deletable?(user).should be_true
    @discussion1.is_deletable?(user).should be_false
  end

  it "should validate valid url" do
    Discussion.is_valid_url?("http://goggle.google").should be_false
    Discussion.is_valid_url?("http://yahoo.com").should be_false
    Discussion.is_valid_url?("http://google.com").should be_true
  end

  it "should validate valid url" do
    @discussion1 = discussions(:one)
    user = users(:one)
    @group =  Group.create(:name=>"My group",:user_id=>user.id)
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'jalendraa.bhanarkar@cipher-tech.com',:invitation_type=>"Added")
    @user1 = User.create(:username=>"Jalendraa",:encrypted_password=>"b0e1d0d604a188cb8f9d32b93405f29ad5914a8b",:system_role=> 10,:email=> "jalendraa.bhanarkar@cipher-tech.com")
    GroupUser.create(:user_id=>@user1.id, :group_id=>@group.id)
    SharedTab.create(:shareable_id=>@discussion1, :group_id=>@group.id, :shareable_type=>"Discussion")
    @discussion1.send_mails_to_non_site_crowd_user(user, "http://convorum.com")
  end
  
end
