require 'spec_helper'

describe Group do
  fixtures :users
  before(:each) do
    @group = Group.new(:name=>'My group', :user_id => 1)
  end

  it "should be invalid without a name" do
    @group.name = ''
    @group.should_not be_valid
  end
  it "should be invalid with name having more than 50 characters" do
    @group.name = 'x'*51
    @group.should_not be_valid
  end
  it "should be invalid with existing name " do
    Group.create(:name=>"My group",:user_id=>1)
    @group.should_not be_valid
  end

  it "should return true if default group" do
    @d_group = Group.create(:name=>"Default",:user_id=>1)
    @d_group.is_default_group?.should be_true
  end

  it "should return true if user is member of the group" do
    @d_group = Group.create(:name=>"Default",:user_id=>1)
    user = users(:one)
    GroupUser.create(:user_id=>user.id,:group_id=>@d_group.id)
    @d_group.is_group_member?(user.id).should be_true
  end

  it "should return true if email is non site member of the group" do
    @d_group = Group.create(:name=>"Default",:user_id=>1)
    @d_group.is_non_site_member?("hemant.dhanore@cipher-tech.com").should be_false
    NonSiteUser.create(:invitable_id => @d_group.id, :email => "hemant.dhanore@cipher-tech.com", :invitable_type => 'Group')
    @d_group.is_non_site_member?("hemant.dhanore@cipher-tech.com").should be_true
  end

  it "should return non site members of the group" do
    @d_group = Group.create(:name=>"Nice",:user_id=>1)
    @d_group.non_site_members.count.should eql(0)
    NonSiteUser.create(:invitable_id => @d_group.id, :email => "hemant.dhanore@cipher-tech.com", :invitable_type => 'Group')
    @d_group.non_site_members.count.should eql(1)
  end

  

  
end
