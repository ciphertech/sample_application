require 'spec_helper'

describe "messages/edit.html.erb" do
  before(:each) do
    @message = assign(:message, stub_model(Message,
      :sender_id => 1,
      :receiver_id => 1,
      :message => "MyText",
      :deleted_by_sender => false,
      :deleted_by_receiver => false
    ))
  end

  it "renders the edit message form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => messages_path(@message), :method => "post" do
      assert_select "input#message_sender_id", :name => "message[sender_id]"
      assert_select "input#message_receiver_id", :name => "message[receiver_id]"
      assert_select "textarea#message_message", :name => "message[message]"
      assert_select "input#message_deleted_by_sender", :name => "message[deleted_by_sender]"
      assert_select "input#message_deleted_by_receiver", :name => "message[deleted_by_receiver]"
    end
  end
end
