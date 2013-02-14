class DiscussionGroup < ActiveRecord::Base
  belongs_to :user
  has_many :discussion_group_discussions, :dependent => :destroy
  has_many :discussion_group_users, :dependent => :destroy
  has_many :non_site_users, :as => :invitable, :dependent => :destroy
  has_many :images, :as => :imageable, :dependent => :destroy
  has_many :discussions, :through => :discussion_group_discussions
  scope :join_group_user, select("dg.*").joins("dg LEFT JOIN discussion_group_users dgu ON dg.id=dgu.discussion_group_id ").order("dg.name")
  scope :public_member, lambda{ |id| where(["((dg.is_public=? OR dg.is_public=?) AND dgu.user_id=? AND dgu.is_member=?)", true, false, id, true ]) }
  

  validates :name, :presence => {:message => "Group name can't be blank."}, :length => {:maximum => 40}, :uniqueness => {:scope => :user_id}
  validates :description, :presence => {:message => "Group description can't be blank."}, :length => {:maximum => 1000, :message => "Maximum 1000 characters are allowed."}
  #validates :is_public, :presence => {:message => "Please select a privacy option."}

  #--
  #
  #Created on: 04/03/2012
  #Purpose:
  #++ This method is used to find all discussions of that group
  def all_discussions
    Discussion.join_group.group_share_type(self.id, "groups")
  end

  #--
  #
  #Created on: 04/03/2012
  #Purpose:
  #++ This method is used to find all discussions of that group
  def all_group_discussions(page)
    per_page = 20
    off = (page-1)*per_page
    Discussion.join_group.group_share_type(self.id, "groups").limit(per_page).offset(off)
  end

  #--
  #
  #Created on: 06/03/2012
  #Purpose:
  #++ This method is used to find all group users
  def group_users
    DiscussionGroupUser.where("discussion_group_id=? AND is_member=?", self.id, true)
  end

end


