class DiscussionGroupUser < ActiveRecord::Base
  belongs_to :invitable, :polymorphic => true
  belongs_to :discussion_group
  belongs_to :user

  validates :discussion_group_id, :uniqueness => { :scope => :user_id, :message => 'Invitation already sent.'}

end
