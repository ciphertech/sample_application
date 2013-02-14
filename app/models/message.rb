class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'receiver_id'
  
  validates :message, :presence => true, :length => {:maximum => 2000}
  validates :receiver_id, :presence => true# {:message => 'Please select the receiver.'}
  #--                                                    
  #
  #Created on: 07/01/2012
  #Purpose: 
  #++ This method is used to delete the message by sender/receiver
  after_validation :validate_message_sender


  def validate_message_sender
    self.errors.add :receiver_id, "can not be sender." if self.sender_id==self.receiver_id
  end

  def delete_message(user_id)
    var = user_id == self.sender_id ? "sender" : "receiver"
    self.update_attribute("deleted_by_#{var}", true)
  end


end
