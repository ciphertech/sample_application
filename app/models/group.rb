class Group < ActiveRecord::Base
  has_many :group_users, :dependent => :destroy
  has_many :shared_tabs, :dependent => :destroy
  has_many :non_site_users, :as => :invitable, :dependent => :destroy
  belongs_to :user
  validates :name, :presence => true, :uniqueness => {:scope => :user_id}
  validates_length_of :name, :maximum => 50


  #--
  #
  #Created on: 31/01/2012
  #Purpose:
  #++ This method is used is to check if the group is default
  def is_default_group?
    self.name=="Default"
  end

  #--
  #
  #Created on: 16/05/2012
  #Purpose:
  #++ This method is used to find user is a member of a group or not
  def is_group_member?(user_id)
    GroupUser.exists?(:group_id => self.id, :user_id => user_id)
  end

  #--
  #
  #Created on: 16/05/2012
  #Purpose:
  #++ This method is used to find user is a non site member of a group or not
  def is_non_site_member?(email)
    NonSiteUser.exists?(:invitable_id => self.id, :email => email, :invitable_type => 'Group')
  end

  #--
  #
  #Created on: 16/05/2012
  #Purpose:
  #++ This method is used to find all non site members of a crowd or not
  def non_site_members
    NonSiteUser.where({:invitable_id => self.id, :invitable_type => "Group"})
  end


end
