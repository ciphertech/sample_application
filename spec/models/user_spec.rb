require 'spec_helper'

describe User do
  fixtures :users, :discussions, :tabs, :shared_tabs, :groups,:albums, :pictures, :comments, :non_site_users
  before(:each) do
    @user = User.new(:email=>'a@b.com', :encrypted_password => 'some_passowrd', :username=>"someusername")
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>"a@b.com",:invitation_type=>"Added")
  end

  it "should be invalid without a email" do
    @user.email = ''
    @user.should_not be_valid
    @user.errors[:email] == "cannot be blank."
  end

  it "should be invalid without a encrypted_password" do
    @user.encrypted_password = ''
    @user.should_not be_valid
    @user.errors[:encrypted_password] == "cannot be blank."
  end

=begin
  it "should be invalid with a encrypted_password more than 20 or less than 6 characters" do
    @user.encrypted_password = 'a'*5
    @user.should_not be_valid
    @user.encrypted_password = 'a'*21
    @user.should_not be_valid
    @user.encrypted_password = 'a'*11
    @user.should be_valid
  end
=end


  it "should be invalid with a email more than 100 characters" do
    
    @user.email = 'a'*101
    @user.should_not be_valid
    @user.email = 'a@b.com'
    @user.should be_valid
  end

  it "should be invalid without a username" do
    @user.username = ''
    @user.should_not be_valid
    @user.errors[:username] == "cannot be blank."
  end

  it "should be invalid with a username more than 50 characters" do
    @user.username = 'a'*51
    @user.should_not be_valid
  end

  it "should be valid with a username less than 51 characters" do
    @user.username = 'a'*50
    @user.should be_valid
  end

  it "should return nil when username, passowrd doesn't match" do
    @user = User.create(:email=>'a@b.com', :encrypted_password => 'some_passowrd', :username=>"someusername")
    User.authenticate("someusername", 'some_passowrd').should eql(nil)
  end

  it "should return nil when user is not active for user whose username, passowrd match" do
    @user = User.create(:email=>'a@b.com', :encrypted_password => 'some_passowrd', :username=>"someusername")
    User.authenticate("someusername", 'some_passowrd').should eql(nil)
  end

  it "should return nil when user is active for user whose username, passowrd match" do
    @user = User.create(:email=>'a@b.com', :encrypted_password => 'some_passowrd', :username=>"someusername")
    @user.activate
    User.authenticate("someusername", 'some_passowrd').should eql(@user)
  end

  it "should activate user and allow to login" do
    @user = User.create(:email=>'a@b.com', :encrypted_password => 'some_passowrd', :username=>"someusername")
    @user.confirmation_token.should_not be_nil
    @user.account_status.should eql('pending')
    @user.activate
    @user.confirmation_token.should be_nil
    @user.account_status.should eql('active')
  end

  it "should be invalid if username already present" do
    @user = User.create(:email=>'a@b.com', :encrypted_password => 'some_passowrd', :username=>"uniqueusername", :account_status => 'active')
    @user.should be_valid
    @other_user = User.create(:email=>'aasd@b.com', :encrypted_password => 'some_passowrd', :username=>"uniqueusername", :account_status => 'active')
    @other_user.should_not be_valid
  end

  it "should return inbox/sent messages for user which is not deleted by user in respective section" do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'sender@b.com',:invitation_type=>"Added")
    @sender = User.create(:email=>'sender@b.com', :encrypted_password => 'some_passowrd', :username=>"senderusername", :account_status => 'active')
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'receiver@b.com',:invitation_type=>"Added")
    @receiver = User.create(:email=>'receiver@b.com', :encrypted_password => 'some_passowrd', :username=>"receiverusername", :account_status => 'active')
    Message.create(:receiver_id => @receiver.id, :sender_id => @sender.id, :deleted_by_receiver => true, :deleted_by_sender => false, :message => "Hi")
    Message.create(:receiver_id => @receiver.id, :sender_id => @sender.id, :deleted_by_receiver => false, :deleted_by_sender => false, :message => "Hi")
    Message.create(:receiver_id => @receiver.id, :sender_id => @sender.id, :deleted_by_receiver => false, :deleted_by_sender => true, :message => "Hi")
    @receiver.inbox_messages.length.should eql(2)
    @sender.inbox_messages.length.should eql(0)
    @receiver.sent_messages.length.should eql(0)
    @sender.sent_messages.length.should eql(2)
  end

  it "should return true/false depending on user active or not" do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'active@b.com',:invitation_type=>"Added")
    @active = User.create(:email=>'active@b.com', :encrypted_password => 'some_passowrd', :username=>"activeusername")
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'pending@b.com',:invitation_type=>"Added")
    @pending = User.create(:email=>'pending@b.com', :encrypted_password => 'some_passowrd', :username=>"pendingusername")
    @active.activate
    @active.is_active?.should be_true
    @pending.is_active?.should be_false
  end 

  it "should return true/false depending on user active or not" do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'admin@b.com',:invitation_type=>"Added")
    @admin = User.create(:email=>'admin@b.com', :encrypted_password => 'some_passowrd', :username=>"adminusername", :system_role => User::SYSTEM_ROLE_ADMIN_USER)
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'user@b.com',:invitation_type=>"Added")
    @user = User.create(:email=>'user@b.com', :encrypted_password => 'some_passowrd', :username=>"userusername", :system_role => User::SYSTEM_ROLE_USER)
    @admin.is_admin?.should be_true
    @user.is_admin?.should be_false
    @admin.is_user?.should be_false
    @user.is_user?.should be_true
  end 

  it "should find all the users available for the login user to whom he/she can send message" do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'login_user@b.com',:invitation_type=>"Added")
    @login_user = User.create(:email=>'login_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextlogin", :system_role => User::SYSTEM_ROLE_ADMIN_USER)
    @login_user.activate
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'active_user@b.com',:invitation_type=>"Added")
    @active_user = User.create(:email=>'active_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextone", :system_role => User::SYSTEM_ROLE_USER).activate
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'inactive_user@b.com',:invitation_type=>"Added")
    @inactive_user = User.create(:email=>'inactive_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometexttwo", :system_role => User::SYSTEM_ROLE_USER)
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'admin@b.com',:invitation_type=>"Added")
    @admin_user = User.create(:email=>'admin@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextthree", :system_role => User::SYSTEM_ROLE_ADMIN_USER).activate
    @login_user.all_message_users('sometext').length.should eql(1)
  end 

  it "should find all the users to who either follows login user or followed by login user" do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'login_user@b.com',:invitation_type=>"Added")
    @login_user = User.create(:email=>'login_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextlogin", :system_role => User::SYSTEM_ROLE_ADMIN_USER)
    @login_user.activate
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'active_user@b.com',:invitation_type=>"Added")
    @active_user = User.create(:email=>'active_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextone", :system_role => User::SYSTEM_ROLE_USER)
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'inactive_user@b.com',:invitation_type=>"Added")
    @inactive_user = User.create(:email=>'inactive_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometexttwo", :system_role => User::SYSTEM_ROLE_USER)
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'admin@b.com',:invitation_type=>"Added")
    @admin_user = User.create(:email=>'admin@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextthree", :system_role => User::SYSTEM_ROLE_ADMIN_USER).activate
    @login_user.from_follower_following('sometext').length.should eql(0)
    @active_user.activate
    FollowerFollowing.create(:following_id => @login_user.id, :follower_id => @active_user.id)
    @log_user = User.find @login_user
    @log_user.from_follower_following('sometext').length.should eql(1)
  end 

  it "should find the people using different non blank parameteres" do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'login_user@b.com',:invitation_type=>"Added")
    @login_user = User.create(:email=>'login_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextlogin", :system_role => User::SYSTEM_ROLE_ADMIN_USER)
    @login_user.activate
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'active_user@b.com',:invitation_type=>"Added")
    @active_user = User.create(:email=>'active_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextone", :system_role => User::SYSTEM_ROLE_USER)
    @active_user_detail = @active_user.build_user_detail({'work_info'=>'Cipher Technologies', 'education' => 'BE', 'interest_internet'=> 'NEWS', 'about_me'=> 'Girl', 'sex' =>'female', 'age' =>25})
    @active_user.save
    @active_user.activate
    @log_user = User.find @login_user
    option = {'username' =>'some', 'work_info'=>'Cipher', 'education' => 'BE', 'interest_internet'=>'NEWS', 'about_me' => 'Girl', 'sex' =>'female', 'age_to' =>28, 'age_from' =>18}
    @log_user.search_query(option).length.should eql(1)
    option = {'username' =>'some', 'work_info'=>'Cipher', 'education' => 'BE', 'interest_internet'=>'NEWS', 'about_me' => 'Girl', 'sex' =>'female', 'age_to' =>28, 'age_from' =>18, 'tab'=> 'anytab'}
    @log_user.search_query(option).length.should eql(0)
  end

  it "show thumbnail for different size " do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'login_user@b.com',:invitation_type=>"Added")
    @login_user = User.create(:email=>'login_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextlogin", :system_role => User::SYSTEM_ROLE_ADMIN_USER)
    @login_user.profile_pic(:small).should eql("/images/profile_image.jpg")
    @pic=ProfilePicture.create(:photo_file_name => "profile.jpg", :photo_file_size => 8774, :photo_content_type => "image/jpeg", :user_id => @login_user.id)
    @log_user = User.find @login_user
    File.stub(:exist?).and_return(true)
    @log_user.profile_pic(:small).should eql("/profile_pictures/photos/#{@pic.id}/small_profile.jpg")
    @log_user.profile_pic(:medium).should eql("/profile_pictures/photos/#{@pic.id}/medium_profile.jpg")
    @log_user.profile_pic(:large).should eql("/profile_pictures/photos/#{@pic.id}/large_profile.jpg")
  end

  it "return the path of the user's profile "  do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'login_user@b.com',:invitation_type=>"Added")
    @profile_user = User.create(:email=>'login_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextlogin", :system_role => User::SYSTEM_ROLE_USER)
    @log_user = User.find @profile_user
    @log_user.profile_path.should eql("/users/profile/#{@log_user.id}")
  end

  it "should return true/false depending on whether user follows param users or not " do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'login_user@b.com',:invitation_type=>"Added")
    @login_user = User.create(:email=>'login_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextlogin", :system_role => User::SYSTEM_ROLE_ADMIN_USER)
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'active_user@b.com',:invitation_type=>"Added")
    @other_user = User.create(:email=>'active_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextone", :system_role => User::SYSTEM_ROLE_USER)
    @log_user = User.find @login_user
    @oth_user = User.find @other_user
    @log_user.is_following?(@oth_user.id).should be_false
    FollowerFollowing.create(:following_id => @other_user.id, :follower_id => @login_user.id)
    @log_user.is_following?(@oth_user.id).should be_true
  end 

  it "should return true/false depending on whether param user follows users or not " do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'login_user@b.com',:invitation_type=>"Added")
    @login_user = User.create(:email=>'login_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextlogin", :system_role => User::SYSTEM_ROLE_ADMIN_USER)
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'active_user@b.com',:invitation_type=>"Added")
    @other_user = User.create(:email=>'active_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextone", :system_role => User::SYSTEM_ROLE_USER)
    @log_user = User.find @login_user
    @oth_user = User.find @other_user
    @log_user.is_follower?(@oth_user.id).should be_false
    FollowerFollowing.create(:following_id => @login_user.id, :follower_id => @other_user.id)
    @log_user.is_follower?(@oth_user.id).should be_true
  end 

  it "should return the username " do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'login_user@b.com',:invitation_type=>"Added")
    @login_user = User.create(:email=>'login_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextlogin", :system_role => User::SYSTEM_ROLE_ADMIN_USER)
    @log_user = User.find @login_user
    @log_user.login.should eql('sometextlogin')
  end 

  it "should return false when login user is admin " do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'login_user@b.com',:invitation_type=>"Added")
    @login_user = User.create(:email=>'login_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextlogin", :system_role => User::SYSTEM_ROLE_ADMIN_USER)
    @log_user = User.find @login_user
    @log_user.is_rater?(Comment.new).should be_false
  end

  it "should return true/false when login user is of type user and already rate the comment/discussion or not" do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'login_user@b.com',:invitation_type=>"Added")
    @login_user = User.create(:email=>'login_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextlogin", :system_role => User::SYSTEM_ROLE_USER)
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'active_user@b.com',:invitation_type=>"Added")
    @other_user = User.create(:email=>'active_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextone", :system_role => User::SYSTEM_ROLE_USER)
    @discussion = Discussion.create(:discussion => "http://www.google.com")
    UserDiscussion.create(:user_id => @other_user.id, :discussion_id => @discussion.id)
    @comment = Comment.create(:user_id => @other_user.id, :discussion_id => @discussion.id, :comment => "Hello")
    @log_user = User.find @login_user
    @log_user.is_rater?(@discussion).should be_false
    @log_user.is_rater?(@comment).should be_false
  end

  it "should return true/false depending on whether param user follows users or not " do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'login_user@b.com',:invitation_type=>"Added")
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'active_user@b.com',:invitation_type=>"Added")
    @login_user = User.create(:email=>'login_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextlogin", :system_role => User::SYSTEM_ROLE_ADMIN_USER)
    @other_user = User.create(:email=>'active_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextone", :system_role => User::SYSTEM_ROLE_USER)
    @log_user = User.find @login_user
    @oth_user = User.find @other_user
    @log_user.is_email_update?(@oth_user.id).should be_false
    FollowerFollowing.create(:following_id => @other_user.id, :follower_id => @login_user.id, :get_email_updates => true)
    @log_user.is_email_update?(@oth_user.id).should be_true
  end 

  it "should add discussion if not already present" do
    old_count = UserDiscussion.count
    disc_count = Discussion.count
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'login_user@b.com',:invitation_type=>"Added")
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'active_user@b.com',:invitation_type=>"Added")
    @login_user = User.create(:email=>'login_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextlogin", :system_role => User::SYSTEM_ROLE_ADMIN_USER)
    @log_user = User.find @login_user
    @login_user.add_discussion?({:discussion =>"http://www.abc.com"}).should_not be_nil
    UserDiscussion.count.should eql(old_count+1)
    Discussion.count.should eql(disc_count+1)
    @login_user.add_discussion?({:discussion =>"http://www.abc.com"}).should_not be_nil
    UserDiscussion.count.should eql(old_count+1)
    Discussion.count.should eql(disc_count+1)
    @other_user = User.create(:email=>'active_user@b.com', :encrypted_password => 'some_passowrd', :username=>"sometextone", :system_role => User::SYSTEM_ROLE_USER)
    @oth_user = User.find @other_user
    @oth_user.add_discussion?({:discussion =>"http://www.abc.com"}).should_not be_nil
    UserDiscussion.count.should eql(old_count+2)
    Discussion.count.should eql(disc_count+1)
  end

  it "should return all public groups of other users" do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'jalendraa.bhanarkar@cipher-tech.com',:invitation_type=>"Added")
    @user = User.create(:username=>"admin123",:encrypted_password=>"b0e1d0d604a188cb8f9d32b93405f29ad5914a8b",:system_role=> 10,:email=> "jalendraa.bhanarkar@cipher-tech.com")
    @user.all_groups(" ").count.should eql(0)
    DiscussionGroup.create(:name=>"Any group",:is_public=>true,:user_id=>1,:description=>"Cool")
    @user.all_groups(" ").count.should eql(1)
  end

  it "should return true or false depending on discussion is discussed by user or not" do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'jalendraa.bhanarkar@cipher-tech.com',:invitation_type=>"Added")
    @user = User.create(:username=>"Jalendra",:encrypted_password=>"b0e1d0d604a188cb8f9d32b93405f29ad5914a8b",:system_role=> 10,:email=> "jalendraa.bhanarkar@cipher-tech.com")
    @d = @user.add_discussion?({:discussion=>"yahhhhhhoooo",:discussion_type=>"Comment/Question",:share_type=>"public"})
    @user.is_discussed?(@d.id).should be_true
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'jalendsraa.bhanarkar@cipher-tech.com',:invitation_type=>"Added")
    @user2 = User.create(:username=>"satish",:encrypted_password=>"b0e1d0d604a188cb8f9d32b93405f29ad5914a8b",:system_role=> 10,:email=> "jalendsraa.bhanarkar@cipher-tech.com")
    @user2.is_discussed?(@d.id).should be_false
  end

  it "should return default crowd of user" do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'jalendraa.bhanarkar@cipher-tech.com',:invitation_type=>"Added")
    @user = User.create(:username=>"Jalendraa",:encrypted_password=>"b0e1d0d604a188cb8f9d32b93405f29ad5914a8b",:system_role=> 10,:email=> "jalendraa.bhanarkar@cipher-tech.com")
    @crowd = Group.create(:name=>"Default",:user_id=>@user.id)
    @crowd2 = Group.create(:name=>"New Group",:user_id=>@user.id)
    @user.default_group[0].should eql(@crowd)
  end

  it "should return groups in which user is belonging" do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'jalendraa.bhanarkar@cipher-tech.com',:invitation_type=>"Added")
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'jaslendraa.bhanarkar@cipher-tech.com',:invitation_type=>"Added")
    @user1 = User.create(:username=>"Jalendraa",:encrypted_password=>"b0e1d0d604a188cb8f9d32b93405f29ad5914a8b",:system_role=> 10,:email=> "jalendraa.bhanarkar@cipher-tech.com")
    @crowd1 = Group.create(:name=>"Default",:user_id=>@user1.id)
    @crowd2 = Group.create(:name=>"Test",:user_id=>@user1.id)
    @user2 = User.create(:username=>"SAtishs123",:encrypted_password=>"b0e1d0d604a188cb8f9d32b93405f29ad5914a8b",:system_role=> 10,:email=> "jaslendraa.bhanarkar@cipher-tech.com")
    @group_user = GroupUser.create(:user_id=>@user2.id,:group_id=>@crowd1.id)
    @user1.belongs_to_group(@user2.id).should eql([])
    @group_user = GroupUser.create(:user_id=>@user2.id,:group_id=>@crowd2.id)
    @user1.belongs_to_group(@user2.id).should_not eql([])
  end

  it "should return group users if the user belongs to any groups" do
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'jalendraa.bhanarkar@cipher-tech.com',:invitation_type=>"Added")
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'jaslendraa.bhanarkar@cipher-tech.com',:invitation_type=>"Added")
    @user1 = User.create(:username=>"Jalendraa",:encrypted_password=>"b0e1d0d604a188cb8f9d32b93405f29ad5914a8b",:system_role=> 10,:email=> "jalendraa.bhanarkar@cipher-tech.com")
    @crowd1 = Group.create(:name=>"Default",:user_id=>@user1.id)
    @crowd2 = Group.create(:name=>"Test",:user_id=>@user1.id)
    @user2 = User.create(:username=>"SAtishs123",:encrypted_password=>"b0e1d0d604a188cb8f9d32b93405f29ad5914a8b",:system_role=> 10,:email=> "jaslendraa.bhanarkar@cipher-tech.com")
    @group_user = GroupUser.create(:user_id=>@user2.id,:group_id=>@crowd1.id)
    @user1.all_groups_having(@user2.id).count.should eql(1)
    @group_user = GroupUser.create(:user_id=>@user2.id,:group_id=>@crowd2.id)
    @user1.all_groups_having(@user2.id).count.should eql(2)
  end

  it "should return the tabs which are shared with user" do
    @user = users(:one)
    @tab = tabs(:one)
    NonSiteUser.create(:invitable_id=>1, :invitable_type=>"Group",:email=>'jalendraa.bhanarkar@cipher-tech.com',:invitation_type=>"Added")
    @user1 = User.create(:username=>"Jalendraa",:encrypted_password=>"b0e1d0d604a188cb8f9d32b93405f29ad5914a8b",:system_role=> 10,:email=> "jalendraa.bhanarkar@cipher-tech.com")
    @group =  groups(:one)
    @group_user = GroupUser.create(:user_id=>@user1.id,:group_id=>@group.id)
    @user1.shared_tabs_with(@user.id).count.should eql(1)
    @user = users(:two)
    @user1.shared_tabs_with(@user.id).count.should eql(3)
    @user.shared_tabs_with(@user.id).count.should eql(4)
  end

  it "should return the groups with which tab is shared" do
    @user = users(:two)
    @tab = tabs(:three)
    @user.groups_having_shared(@tab.id).count.should eql(2)
    @tab = tabs(:one)
    @user.groups_having_shared(@tab.id).count.should eql(0)
  end

  it "should return the groups with which picture is shared" do
    @user = users(:two)
    @pic = pictures(:one)
    @user.groups_having_photo_shared(@pic.id).count.should eql(2)
    @pic = pictures(:two)
    @user.groups_having_photo_shared(@pic.id).count.should eql(1)
  end

  it "should return the groups with which album is shared" do
    @user = users(:one)
    @album = Album.create(:name=>"my album",:user_id=>@user.id,:share_type=>2)
    group = groups(:one)
    SharedTab.create(:group_id=>group.id,:shareable_type=>"Album",:shareable_id=>@album.id)
    @user.groups_having_album_shared(@album.id).count.should eql(1)
    @user = users(:two)
    @user.groups_having_album_shared(@album.id).count.should eql(0)
  end

  it "should return true if the user is member of discussion group" do
    @user1 = users(:one)
    @d_g = DiscussionGroup.create(:name=>"My group",:user_id=>@user1.id,:description=>"LLLLLOL",:is_public=>true)
    @dgu = DiscussionGroupUser.create(:user_id=>@user1.id, :discussion_group_id=>@d_g.id,:is_member=>true)
    @user1.is_member_of_discussion_group(@d_g.id).should be_true

    @user2 = users(:two)
    @d_g = DiscussionGroup.create(:name=>"My group",:user_id=>@user2.id,:description=>"LLLLLOL",:is_public=>true)
    @dgu = DiscussionGroupUser.create(:user_id=>@user2.id, :discussion_group_id=>@d_g.id,:is_member=>false)
    @user2.is_member_of_discussion_group(@d_g.id).should be_false
  end

  it "should return all groups which the user has joined or created" do
    @user1 = users(:one)
    @d_g = DiscussionGroup.create(:name=>"My group",:user_id=>@user1.id,:description=>"LLLLLOL",:is_public=>true)
    @dgu = DiscussionGroupUser.create(:user_id=>@user1.id, :discussion_group_id=>@d_g.id,:is_member=>true)
    @d_g = DiscussionGroup.create(:name=>"My sgroup",:user_id=>2,:description=>"LLLLLOL",:is_public=>true)
    @dgu = DiscussionGroupUser.create(:user_id=>@user1.id, :discussion_group_id=>@d_g.id,:is_member=>true)
    @d_g = DiscussionGroup.create(:name=>"My sagroup",:user_id=>3,:description=>"LLLLLOL",:is_public=>false)
    @dgu = DiscussionGroupUser.create(:user_id=>@user1.id, :discussion_group_id=>@d_g.id,:is_member=>true)
    @user1.all_public_private_groups.count.should eql(3)
    @d_g = DiscussionGroup.create(:name=>"My sagroup",:user_id=>5,:description=>"LLLLLOL",:is_public=>false)
    @user1.all_public_private_groups.count.should eql(3)
  end

  it "should return all nonsite user if email belongs to the nonsite user for group " do
    @user1 = users(:one)
    @group = groups(:one)
    NonSiteUser.create(:email=>"jalendra.bhanarkar@cipher-tech.com", :invitable_id=>@group.id, :invitable_type=>"Group")
    @user1.all_crowd_having_email("satish@cipher-tech.com").count.should eql(0)
    @user1.all_crowd_having_email("jalendra.bhanarkar@cipher-tech.com").count.should eql(1)
  end

  it "should add nonsite user to group and to following of user" do
    @user1 = users(:one)
    @group = groups(:one)
    NonSiteUser.create(:email=>"satish12345@cipher-tech.com", :invitable_id=>@group.id, :invitable_type=>"Group")
    count = NonSiteUser.all.count
    @group.group_users.count.should eql(2)
    @user2 = User.create(:username=>"satish1233",:encrypted_password=>"b0e1d0d604a188cb8f9d32b93405f29ad5914a8b",:system_role=> 10,:email=> "satish12345@cipher-tech.com")
    @user2.add_non_site_to_site_member
    @group.group_users.count.should eql(3)
    NonSiteUser.all.count.should eql(count-1)
  end
  
  it "should add nonsite user to group and to following of user" do
    @user1 = users(:one)
    @user1.find_public_groups(" ",1).count.should eql(0)
    DiscussionGroup.create(:name=>"My group",:user_id=>@user1.id,:description=>"woo",:is_public=>true)
    DiscussionGroup.create(:name=>"Friends",:user_id=>@user1.id,:description=>"the desc",:is_public=>true)
    DiscussionGroup.create(:name=>"My Family",:user_id=>@user1.id,:description=>"LLLLLOL",:is_public=>true)
    @user1.find_public_groups(" ",1).count.should eql(3)
    @user1.find_public_groups("Friends",1).count.should eql(1)
    @user1.find_public_groups("My",1).count.should eql(2)
    @user1.find_public_groups("woo",1).count.should eql(1)
  end


  it "should return the discussions that are commented" do
    @user1 = users(:one)
    @user1.commented_discussions.count.should eql(1)
    @user2 = users(:two)
    @user2.commented_discussions.count.should eql(0)
  end

  it "should return albums visible to the user" do
    @user1 = users(:one)
    Album.create(:name=>"My 1 albim",:user_id=>@user1.id,:share_type=>1)
    Album.create(:name=>"My 2 albim",:user_id=>@user1.id,:share_type=>0)
    @a = Album.create(:name=>"My 3 albim",:user_id=>@user1.id,:share_type=>2)
    @user1.shared_albums(@user1.id).count.should eql(4)
    @user2 = users(:two)
    @user1.shared_albums(@user2.id).count.should eql(2)
    SharedTab.create(:shareable_type=>"Album",:shareable_id=>@a.id,:group_id=>1)
    GroupUser.create(:group_id=>1,:user_id=>@user2.id)
    @user1.shared_albums(@user2.id).count.should eql(3)
  end

  it "should return all pictures that should be visible to user" do
    @user1 = users(:one)
    a = albums(:one)
    @user2 = users(:three)
    @user2.all_visible_pictures((Time.now - 30.day), Time.now,1,false, 0,0).count.should eql(5)
    p = pictures(:one)
    g = groups(:one)
    SharedTab.create(:shareable_type=>"Picture",:shareable_id=>p.id,:group_id=>g.id)
    GroupUser.create(:group_id=>g.id,:user_id=>@user2.id)
    @user2.all_visible_pictures((Time.now - 30.day), Time.now,1,false, 0,0).count.should eql(6)

    grp = Group.create(:user_id=>@user2.id,:name=>"Latest")
    GroupUser.create(:group_id=>grp.id,:user_id=>@user1.id)
    @user2.all_visible_pictures((Time.now - 30.day), Time.now,1,false, 0,grp.id).count.should eql(6)

    d_grp = DiscussionGroup.create(:user_id=>@user2.id,:name=>"Latest",:is_public=>true,:description=>"dsds")
    @user2.all_visible_pictures((Time.now - 30.day), Time.now,1,false, d_grp.id,0).count.should eql(0)
    a= DiscussionGroupUser.create(:discussion_group_id=>d_grp.id,:user_id=>@user1.id,:is_member=>true)
    b = DiscussionGroupUser.create(:discussion_group_id=>d_grp.id,:user_id=>@user2.id,:is_member=>true)
    @user2.all_visible_pictures((Time.now - 30.day), Time.now,1,false, d_grp.id,0).count.should eql(6)
  end

  it "should return feeds " do
    @user2 = users(:two)
    @user1 = users(:one)
    @user2.feed(Time.now-30.days, Time.now).count.should eql(14)
    @d = @user1.add_discussion?({:discussion=>"yahhhhhhoooo",:discussion_type=>"Comment/Question",:share_type=>"public"})
    FollowerFollowing.create(:follower_id=>@user1.id, :following_id=>@user2.id,:get_email_updates=>true)
    @user2.feed(Time.now-30.days, Time.now).count.should eql(16)
  end
  
end
