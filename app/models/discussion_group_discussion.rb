class DiscussionGroupDiscussion < ActiveRecord::Base
  belongs_to :discussion
  belongs_to :discussion_group

  validates :discussion_group_id, :uniqueness => { :scope => :discussion_id, :message => 'Discussion already posted in this group.'}
end
