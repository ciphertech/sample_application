require 'spec_helper'

describe "user_discussions/show.html.erb" do
  before(:each) do
    @user_discussion = assign(:user_discussion, stub_model(UserDiscussion,
      :user_id => 1,
      :discussion_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
