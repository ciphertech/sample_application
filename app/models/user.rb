class User < ActiveRecord::Base
  has_one :user_detail
  has_many :followers, :class_name => 'FollowerFollowing', :foreign_key => 'following_id'
  has_many :followings, :class_name => 'FollowerFollowing', :foreign_key => 'follower_id'
  has_many :receivers, :class_name => 'Message', :foreign_key => 'receiver_id'
  has_many :senders, :class_name => 'Message', :foreign_key => 'sender_id'
  has_many :tabs
  has_many :comments
  has_many :ratings

  scope :select_rate, select('DISTINCT u.*').joins("u LEFT JOIN ratings r ON u.id = r.user_id")
  scope :raters, lambda{ |id, class_name|  select_rate.where(["r.rateable_id=? and r.rateable_type=?", id, class_name])}

  SYSTEM_ROLE_ADMIN_USER = 90
  SYSTEM_ROLE_USER = 10
  SECURITY_KEY = 'mmm, salty passwords'

  #ajaxful_rater
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :username, :uniqueness => { :message => "Username has already been taken." },
    :presence => { :message => "Username can't be blank." },
    :length => { :maximum => 50, :message => "Username should not exceed 50 characters." }
  validates :encrypted_password, :presence => {:message => 'Password cannot be blank.'}
  validates :email, :uniqueness => { :message => 'Email has already been taken.'},
    :presence => { :message => "Email can't be blank." },
    :length => { :maximum => 100, :message => "Email should not exceed 100 characters." },
    :format => { :with => email_regex, :message => "Email is not valid." }

  validate :invited_email, :on => :create
  before_create :make_confirmation_token
  after_validation :set_hash_password


  def invited_email
    errors.add(:email, "Sorry! You must receive an invite in order to signup with Convorum.") if NonSiteUser.where("email='#{email}'").blank?
  end
  #--
  #
  #Created on: 06/01/2012
  #Purpose:
  #++ This method is used when user click on the activation link to change the status of user from 'pending' to 'active'
  def activate
    self.confirmation_token = nil
    self.account_status = 'active'
    save(:validate => false)
  end

  #--
  #
  #Created on: 06/01/2012
  #Purpose:
  #++ This method is used when user is created to create confirmation_token for the activation link
  def make_confirmation_token
    self.confirmation_token = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    self.account_status = 'pending' if self.system_role != SYSTEM_ROLE_ADMIN_USER
  end

  #--
  #
  #Created on: 06/01/2012
  #Purpose:
  #++ This method is used to encrypt the password after validation
  def set_hash_password
    # update password if password was set
    self.encrypted_password = User.hash_password(encrypted_password)  if !encrypted_password.blank? && encrypted_password.length < 32
    #filtered_errors = self.errors.reject{ |err| %w{ user_detail }.include?(err.first) }
    #self.errors.clear
    #filtered_errors.each { |err| self.errors.add(*err) }
  end

  #--
  #
  #Created on: 06/01/2012
  #Purpose:
  #++ This method is return user if username and password is correct during login and is active
  def self.authenticate(username, pass)
    user = User.where("username = ? AND encrypted_password = ? AND account_status = ?", username, User.hash_password(pass), 'active').first
    return user
  end

  #--
  #
  #Created on: 06/01/2012
  #Purpose:
  #++ This method is used to find all the message of the Inbox for User
  def inbox_messages
    self.receivers.where("deleted_by_receiver = ? OR deleted_by_receiver is ?", false, nil).order("created_at DESC")
  end

  #--
  #
  #Created on: 06/01/2012
  #Purpose:
  #++ This method is used to find all the message of the Sent Messages for User
  def sent_messages
    self.senders.where("deleted_by_sender = ? OR deleted_by_sender is ?", false, nil).order("created_at DESC")
  end

  #--
  #
  #Created on: 06/01/2012
  #Purpose:
  #++ This method return true/false depending on user active or not
  def is_active?
    !!(self.account_status == 'active')
  end

  #--
  #
  #Created on: 06/01/2012
  #Purpose:
  #++ This method return true/false depending on user admin or user
  def is_admin?
    !!(self.system_role == SYSTEM_ROLE_ADMIN_USER)
  end

  #--
  #
  #Created on: 06/01/2012
  #Purpose:
  #++ This method return true/false depending on user user or admin
  def is_user?
    !!(self.system_role == SYSTEM_ROLE_USER)
  end

  #--
  #
  #Created on: 07/01/2012
  #Purpose:
  #++ Find all the users available for the login user to whom he can send message
  def all_message_users(search_text)
    User.where("id !=? AND account_status = ? AND system_role != ? AND username LIKE ?", self.id, 'active', SYSTEM_ROLE_ADMIN_USER, "%#{search_text}%")
  end

  #--
  #
  #Created on: 07/01/2012
  #Purpose:
  #++ Find all the users to who either follows login user or followed by login user
  def from_follower_following(search_text)
    following_array = self.followers.collect{|f| f.follower_id}
    follower_array = self.followings.collect{|f| f.following_id}
    id_array = following_array + follower_array
    User.where("id in (?) AND account_status = ? AND system_role != ? AND username LIKE ?", id_array, 'active', SYSTEM_ROLE_ADMIN_USER, "%#{search_text}%")
  end

  #--
  #
  #Created on: 05/04/2012
  #Purpose:
  #++ Find all the public groups available for the login user to whom he can send invitations
  def all_groups(search_text)
    DiscussionGroup.where("user_id !=? AND is_public=? AND name LIKE ?", self.id, true, "%#{search_text}%")
  end

  #--
  #
  #Created on: 09/01/2012
  #Purpose:
  #++ This method is used to find the people using different parameteres
  def search_query(option,page=1)
    per_page = 20
    off = (page-1)*per_page
    #TO DO:- Remaining Search on the basis of TAG
    where_clause=""
    where_array=[]
    where_clause+=" AND u.system_role!= #{SYSTEM_ROLE_ADMIN_USER}"
    where_clause+=" AND u.username like ?" if option['username'].present?
    where_array << "%#{option['username']}%" if option['username'].present?
    where_clause+=" AND ud.work_info like ?" if option['work_info'].present?
    where_array << "%#{option['work_info']}%" if option['work_info'].present?
    where_clause+=" AND ud.education like ?" if option['education'].present?
    where_array << "%#{option['education']}%" if option['education'].present?
    where_clause+=" AND ud.interest_internet like ?" if option['interest_internet'].present?
    where_array << "%#{option['interest_internet']}%" if option['interest_internet'].present?
    where_clause+=" AND ud.about_me like ?" if option['about_me'].present?
    where_array << "%#{option['about_me']}%" if option['about_me'].present?
    where_clause+=" AND ud.sex = '#{option['sex']}'" if option['sex'].present?
    where_clause+=" AND (ud.age >= #{option['age_from'].to_i} AND ud.age <= #{option['age_to'].to_i})" if option['age_from'].present? && option['age_to'].present?
    if !option['tab'].present?
      users = User.find_by_sql(["SELECT u.* FROM (users u LEFT JOIN user_details ud ON u.id = ud.user_id)
			      WHERE u.id != #{self.id} #{where_clause} ORDER BY u.username LIMIT #{per_page} OFFSET #{off}", *where_array ])
    else
      users = User.find_by_sql(["SELECT u.id FROM (users u LEFT JOIN user_details ud ON u.id = ud.user_id)
			      WHERE u.id != #{self.id} #{where_clause} ORDER BY u.username", *where_array ])
    end

    if option['tab'].present? && users.present?
      user_id = users.collect{|u| u.id }
      users =User.find_by_sql(["SELECT u.* FROM (users u LEFT JOIN tabs t ON t.user_id=u.id
                          LEFT JOIN tab_sites ts ON ts.tab_id=t.id
                          LEFT JOIN shared_tabs s_t ON t.id=s_t.shareable_id AND 'Tab'=s_t.shareable_type
                          LEFT JOIN groups g ON g.id=s_t.group_id
                          LEFT JOIN group_users g_u ON g_u.group_id=g.id
                          LEFT JOIN user_discussions ud ON u.id = ud.user_id
                          LEFT JOIN discussions d ON ud.discussion_id = d.id
                          )
                          WHERE t.user_id in (?) AND ((ts.site_url like ? OR t.name like ?)
                          AND ((t.share_type=2 AND g_u.user_id= ?) OR (t.share_type = ?))) OR d.discussion like ? order by u.username
                           LIMIT #{per_page} OFFSET #{off} ",
          user_id,"%#{option['tab']}%","%#{option['tab']}%",self.id, 0,"%#{option['tab']}%"])
    end
    users.uniq!
    users
  end


  #--
  #
  #Created on: 07/01/2012
  #Purpose:
  #++ This method to find a discussion url.
  def add_discussion?(discussion)
    return self.discussions.where("discussion = ?", discussion[:discussion])[0] if ((discussion[:discussion_type]=="Picture" && discussion[:discussion].present?) || discussion[:discussion_type]!="Picture") && self.discussions.where("discussion = ?", discussion[:discussion]).present?
    disc = Discussion.find_by_discussion(discussion[:discussion])
    if disc.present? && ((discussion[:discussion_type]=="Picture" && discussion[:discussion].present?) || discussion[:discussion_type]!="Picture")
      discuss = UserDiscussion.new(:user_id => self.id, :discussion_id => disc.id )
    else
      discuss = Discussion.new(discussion)
      user_discussion = discuss.user_discussions.build
      user_discussion.user_id = self.id
    end
    #(discuss.save and !disc.present?) ? discuss : nil
    discuss.save ? discuss : nil
  end

   #--
  #
  #Created on: 14/08/2012
  #Purpose:
  #++ This method to find a discussion url while adding multiple picture uploading.
  def add_multiple_discussion?(discussion,key)
    return self.discussions.where("discussion = ?", discussion[:discussion])[0] if ((discussion[:discussion_type]=="Picture" && discussion[:discussion].present?) || discussion[:discussion_type]!="Picture") && self.discussions.where("discussion = ?", discussion[:discussion]).present?
    disc = Discussion.find_by_discussion(discussion[:discussion])
    if disc.present? && ((discussion[:discussion_type]=="Picture" && discussion[:discussion].present?) || discussion[:discussion_type]!="Picture")
      discuss = UserDiscussion.new(:user_id => self.id, :discussion_id => disc.id )
    else
      discuss = Discussion.new(:title => "title", :discussion => "discussion", :discussion_type => "#{key}", :share_type => "groups")
      user_discussion = discuss.user_discussions.build
      user_discussion.user_id = self.id
    end
    #(discuss.save and !disc.present?) ? discuss : nil
    discuss.save ? discuss : nil
  end

  #--
  #
  #Created on: 23/01/2012
  #Purpose:
  #++ This method is used to find a discussion is discussed by user or not
  def is_discussed?(discussion_id)
    UserDiscussion.exists?(:discussion_id => discussion_id, :user_id => self.id)
  end


  #--
  #
  #Created on: 10/01/2012
  #Purpose:
  #++ This method is use to show thumbnail for different size
  def profile_pic(thumb)
    return "/images/profile_image.jpg" unless self.profile_pictures.present?
    file = self.profile_pictures.last.photo(thumb)
    File.exist?("#{RAILS_ROOT}/public/#{file}") ? file : "/images/profile_image.jpg"
  end
  #--
  #
  #Created on: 10/01/2012
  #Purpose:
  #++ This method is required for the acts_as_rateable gem
  def login
    self.username
  end

  #--
  #
  #Created on: 12/01/2012
  #Purpose:
  #++ This method is use to show feeds for login user for last one month
  def feed(from, to, group_id=nil)
    #from, to = (Time.now-30.day), Time.now
    followers, followings = self.followers.collect{ |f| f.follower_id }, self.followings.collect{ |f| f.following_id }
    followers_followings = followers+followings
    group_members = DiscussionGroupUser.find(:all, :conditions => ['discussion_group_id=?', group_id], :select => :user_id) if group_id != nil
    ff = FollowerFollowing.where('follower_id in (?) AND created_at>=? and created_at<=?', followers_followings, from, to).order('created_at desc')
    tab_sites = tab_sites = TabSite.find_by_sql(["SELECT ts.* FROM (tab_sites ts LEFT JOIN tabs t ON ts.tab_id=t.id
                          LEFT JOIN shared_tabs s_t ON t.id=s_t.shareable_id AND 'Tab'=s_t.shareable_type
                          LEFT JOIN groups g ON g.id=s_t.group_id LEFT JOIN group_users g_u ON g_u.group_id=g.id)
                          WHERE (t.user_id in (?) AND ((t.share_type=2 AND g_u.user_id= ?) OR (t.share_type = ?))) AND ts.created_at>=? and ts.created_at<=? ORDER BY t.created_at DESC ",
        followers_followings, self.id, 0, from, to])
    ## added by Jalendra for shared tabs feeds
    shared_tabs = Tab.find_by_sql(["SELECT t.* FROM (tabs t LEFT JOIN shared_tabs s_t ON t.id=s_t.shareable_id AND 'Tab'=s_t.shareable_type
                          LEFT JOIN groups g ON g.id=s_t.group_id LEFT JOIN group_users g_u ON g_u.group_id=g.id)
                          WHERE (t.user_id in (?) AND ((t.share_type=2 AND g_u.user_id= ?) OR (t.share_type = ?))) AND t.created_at>=? and t.created_at<=?  ORDER BY t.created_at DESC ",
        followers_followings, self.id, 0, from, to])

    ## added by Jalendra for shared tabs feeds
    shared_pics = Picture.find_by_sql(["SELECT p.* FROM (pictures p LEFT JOIN shared_tabs s_t ON p.id=s_t.shareable_id AND 'Picture'=s_t.shareable_type
                          LEFT JOIN albums a ON a.id=p.album_id
                          LEFT JOIN groups g ON g.id=s_t.group_id
                          LEFT JOIN group_users g_u ON g_u.group_id=g.id)
                          WHERE (a.user_id in (?) AND ((p.share_type=2 AND g_u.user_id= ?) OR (p.share_type = ?))) AND p.created_at>=? and p.created_at<=? ORDER BY p.created_at DESC",
        followers_followings, self.id, 0, from, to])
                      
    ######
    str = group_id ? " dg.id=#{group_id} AND " : ''
    comments = Comment.where('user_id in (?) AND created_at>=? and created_at<=?',followers_followings, from, to).order('created_at desc')
    user_discussions = UserDiscussion.find_by_sql(["SELECT ud.* FROM user_discussions ud
                          LEFT JOIN discussions d on ud.discussion_id = d.id
                          LEFT JOIN discussion_group_discussions dgd ON dgd.discussion_id = d.id
                          LEFT JOIN discussion_groups dg ON dg.id = dgd.discussion_group_id
                          LEFT JOIN discussion_group_users dgu ON dgu.discussion_group_id = dg.id
                          WHERE #{str} ((d.share_type='public') OR (d.share_type='groups' AND dgu.user_id=? )) AND (ud.user_id in (?) AND ud.created_at>=? and ud.created_at<=?)", self.id, followers_followings, from, to])
    ## added by jalendra
    ## to sort the feeds
    feeds = Array.new
    feeds = (ff + tab_sites + comments + user_discussions + shared_tabs + shared_pics).sort { |a,b|
      if a.updated_at && b.updated_at
        response = 0
        if a.updated_at > b.updated_at then response = -1 end
        if b.updated_at > a.updated_at then response = 1 end
        response
      end
    }
    feeds
    #[ff, tab_sites, comments, user_discussions, shared_tabs, shared_pics]
  end


  #--
  #
  #Created on: 13/01/2012
  #Purpose:
  #++ This method is used is return true/false depending on whether user able to rate or not given disucssion/comment
  def is_rater?(rating_for)
    return false if self.is_admin?
    user_section = rating_for.class == Comment ? (rating_for.user_id == self.id) : (rating_for.user_ids.include?(self.id))
  end

  #--
  #
  #Created on: 13/01/2012
  #Purpose:
  #++ This method is used is to return true/false depending on whether user follows param users or not
  def is_following?(user_id)
    self.followings.where("following_id = ?", user_id).present?
  end

  #--
  #
  #Created on: 13/01/2012
  #Purpose:
  #++ This method is used is to return true/false depending on whether param user follows users or not
  def is_follower?(user_id)
    self.followers.where("follower_id= ?", user_id).present?
  end

  #--
  #
  #Created on: 23/01/2012
  #Purpose:
  #++ This method is used is to return true/false depending on whether param user follows users or not
  def is_email_update?(user_id)
    self.followings.where("following_id = ? AND get_email_updates = true", user_id).present?
  end

  #--
  #
  #Created on: 13/01/2012
  #Purpose:
  #++ This method is used is to return the path of the user's profile
  def profile_path
    "/users/profile/#{self.id}"
  end

  #--
  #
  #Created on: 31/01/2012
  #Purpose:
  #++ This method is used is to return the default group of user
  def default_group
    self.groups.where("name=?","Default")
  end

  #--
  #
  #Created on: 31/01/2012
  #Purpose:
  #++ This method is used is to check user belongs to any group other than Default
  def belongs_to_group(u_id)
    GroupUser.find_by_sql(["SELECT g.* FROM (group_users gu LEFT JOIN groups g ON g.id=gu.group_id) WHERE (g.user_id=#{self.id} AND gu.user_id=#{u_id}) AND g.name!='Default'"])
  end

  #--
  #
  #Created on: 31/01/2012
  #Purpose:
  #++ This method is used is to check user belongs to any group
  def all_groups_having(u_id)
    GroupUser.find_by_sql(["SELECT g.* FROM (group_users gu LEFT JOIN groups g ON g.id=gu.group_id) WHERE (g.user_id=#{self.id} AND gu.user_id=#{u_id})"])
  end

  #--
  #
  #Created on: 01/02/2012
  #Purpose:
  #++ This method is used is to get all tabs that are shared with user
  def shared_tabs_with(u_id)
    if self.id != u_id
      Tab.find_by_sql(["SELECT t.* FROM (tabs t LEFT JOIN shared_tabs s_t ON t.id=s_t.shareable_id AND 'Tab'=s_t.shareable_type
                          LEFT JOIN groups g ON g.id=s_t.group_id LEFT JOIN group_users g_u ON g_u.group_id=g.id)
                          WHERE t.user_id= ? AND ((t.share_type=2 AND g_u.user_id= ?) OR (t.share_type = ?)) ORDER BY t.created_at DESC ",
          u_id, self.id, 0])
    else
      Tab.find(:all,:conditions=>['user_id=? ', u_id], :order=>'created_at DESC')
    end
  end

  #--
  #
  #Created on: 01/02/2012
  #Purpose:
  #++ This method is used to ge all groups with which tab is shared
  def groups_having_shared(t_id)
    Group.find_by_sql(["SELECT g.* FROM (tabs t LEFT JOIN shared_tabs s_t ON t.id=s_t.shareable_id AND 'Tab'=s_t.shareable_type
                          LEFT JOIN groups g ON g.id=s_t.group_id)
                          WHERE t.id=? AND t.user_id=?",t_id,self.id
      ])
  end

  #--
  #
  #Created on: 14/02/2012
  #Purpose:
  #++ This method is used to ge all groups with which tab is shared
  def groups_having_album_shared(a_id)
    Group.find_by_sql(["SELECT g.* FROM (albums a LEFT JOIN shared_tabs s_t ON a.id = s_t.shareable_id AND 'Album' = s_t.shareable_type
                          LEFT JOIN groups g ON g.id=s_t.group_id)
                          WHERE a.id=? AND a.user_id=?", a_id, self.id
      ])
  end

  #--
  #
  #Created on: 16/02/2012
  #Purpose:
  #++ This method is used to ge all groups with which tab is shared
  def groups_having_photo_shared(p_id)
    Group.find_by_sql(["SELECT g.* FROM (pictures p LEFT JOIN shared_tabs s_t ON p.id = s_t.shareable_id AND 'Picture' = s_t.shareable_type
                          LEFT JOIN groups g ON g.id=s_t.group_id)
                          WHERE p.id=?", p_id
      ])
  end

  #--
  #
  #Created on: 16/02/2012
  #Purpose:This method is used to get all pictures that should be visible to user(sorting)
  #++
  def all_visible_pictures(from, to,page=1,order_by_rating=false, group_id=0,crowd_id=0)
    per_page = 20
    off = (page-1)*per_page
    select = order_by_rating ? "(SUM(r.score)/COUNT(ra.id)) AS avg," : ""
    join=order_by_rating ? "LEFT JOIN ratings ra on p.id = ra.rateable_id AND 'Picture' = ra.rateable_type LEFT JOIN rates r on ra.rate_id = r.id" : ""
    #order = order_by_rating ? "avg" : "count"
    order = order_by_rating.nil? ? 'p.updated_at' : (order_by_rating ? "avg" : "count")
    group_user_ids,crowd_user_ids = [],[]
    group_user_ids = DiscussionGroupUser.find(:all,:select => "user_id",:conditions=>["discussion_group_id=?", group_id]) if group_id != 0
    crowd_user_ids = GroupUser.find(:all,:select => "user_id",:conditions=>["group_id=?",crowd_id]) if crowd_id != 0
    user_ids = (crowd_user_ids.collect { |c_u|c_u.user_id  } + group_user_ids.collect { |c_u|c_u.user_id  }).uniq
    user_query = user_ids.blank? ? ((group_id!=0 || crowd_id!=0) ? "and a.user_id in (0)" : "" ) : "and a.user_id in (#{user_ids.join(',')})"

    pictures =  Picture.find_by_sql(["SELECT #{select} COUNT(p_c.id) AS count,p.* from (
                           pictures p LEFT JOIN shared_tabs s_t ON p.id = s_t.shareable_id AND 'Picture' = s_t.shareable_type
                           LEFT JOIN photo_comments p_c ON p_c.discussable_id=p.id AND 'Picture'=p_c.discussable_type #{join}
                           LEFT JOIN albums a ON a.id=p.album_id
                           LEFT JOIN groups g ON g.id=s_t.group_id
                           LEFT JOIN group_users gu ON g.id=gu.group_id)
                           WHERE ( p.share_type=0 OR a.user_id=? OR (p.share_type=2 AND gu.user_id=?) OR (p.share_type=1 AND a.user_id=?)) AND a.id is not null AND (p.created_at>=? AND p.created_at<=? ) #{user_query} GROUP BY p.id ORDER BY #{order} DESC LIMIT ? OFFSET ?
        ",self.id,self.id,self.id,from,to,per_page, off])
    pictures.uniq!
    pictures
  end

  #--
  #
  #Created on: 16/02/2012
  #Purpose:
  #++ This method is used to View all pictures that should be shared in group and in public
  def shared_albums(u_id)
    return Album.find(:all, :conditions => ['user_id=?', u_id])if self.id == u_id
    album = Album.find_by_sql(["SELECT a.* from(albums a LEFT JOIN shared_tabs s_t ON a.id = s_t.shareable_id AND 'Album' = s_t.shareable_type
                           LEFT JOIN groups g ON g.id=s_t.group_id
                           LEFT JOIN group_users gu ON g.id=gu.group_id)
                           WHERE (a.user_id=?) AND (a.share_type=0 OR (a.share_type=2 AND gu.user_id=?))", self.id, u_id])

    album.uniq!
    album
  end

  #--
  #
  #Created on: 22/02/2012
  #Purpose:
  #++ This method is used to View all pictures that should be shared in group and in public
  def commented_discussions(page=1)
    per_page = 5
    off = (page-1)*per_page
    Discussion.find_by_sql(["SELECT DISTINCT d.* from(comments c LEFT JOIN discussions d ON d.id=c.discussion_id)
                            WHERE c.user_id=? ORDER BY c.updated_at DESC LIMIT ? OFFSET ?",self.id, per_page, off])
  end

  #--
  #
  #Created on: 04/03/2012
  #Purpose:
  #++ This method is used to find all public groups by string seperated by spaces
  def find_public_groups(search_str, page=1)
    per_page = 10
    off = (page-1)*per_page
    string_arr = search_str.split(" ")
    where_query = []
    where_array=[]
    string_arr.each_with_index do |str,i|
      where_query  <<  "  ( dg.name LIKE ? OR dg.description LIKE ? ) "
      where_array <<  "%#{str}%"
      where_array <<  "%#{str}%"
    end if string_arr.length>0
    #public_query = self.is_admin? ? "(dg.is_public=true OR dg.is_public=false)" : "(dg.is_public=true)"
    public_query = "(dg.is_public=true)"
    query = where_query.join(" AND ")
    DiscussionGroup.find_by_sql(["SELECT DISTINCT dg.* FROM (discussion_groups dg) WHERE (#{public_query} #{query=='' ? '' : 'AND '+query}) LIMIT ? OFFSET ?", *where_array, per_page, off]);
  end

  #--
  #
  #Created on: 05/04/2012
  #Purpose:
  #++ This method is show groups 
  def is_member_of_discussion_group(discussion_group_id)
    DiscussionGroupUser.count(:conditions => ['discussion_group_id=? and user_id=? and is_member=?', discussion_group_id, self.id, true]) > 0
  end

  #--
  #
  #Created on: 07/04/2012
  #Reviewd by: Salil Gaikwad
  #Reviewd on: 27/06/2012
  #Purpose:
  #++ This method is show groups
  def all_public_private_groups
    DiscussionGroup.join_group_user.public_member(self.id)
  end
 
  #--
  #
  #Created on: 16/05/2012
  #Purpose:
  #++ This method is used is to check non site user belongs to any group
  def all_crowd_having_email(email)
    NonSiteUser.find_by_sql(["SELECT g.* FROM (non_site_users nsu LEFT JOIN groups g ON g.id=nsu.invitable_id AND nsu.invitable_type = 'Group') WHERE (g.user_id=#{self.id} AND nsu.email= ? )", email])
  end

  #--
  #
  #Created on: 16/05/2012
  #Purpose:
  #++ This method is used is to add non site user to the member
  def add_non_site_to_site_member
    non_sites = NonSiteUser.find(:all, :conditions => {:email => self.email})
    for site in non_sites
      if site.invitable_type=="Group"
        user = site.invitable.user
        GroupUser.create(:group_id => site.invitable_id, :user_id => self.id)
        FollowerFollowing.create(:follower_id => user.id, :following_id => self.id, :get_email_updates => true) unless self.is_following?(user.id) || self.is_follower?(user.id)
        site.destroy
      elsif site.invitable_type=="DiscussionGroup" && (site.invitation_type=="Invited" || site.invitation_type==nil)
        DiscussionGroupUser.create(:discussion_group_id => site.invitable_id, :user_id => self.id, :is_member => 0)
        site.destroy
      end
    end
  end

  def self.delete_dirty_discussions_data
    log = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}_dsp.log")
    discussions = Discussion.find_by_sql("SELECT d.*, da.attachable_type FROM discussions d LEFT JOIN discussion_attachments da ON d.id = da.attachable_id
			      AND da.attachable_type = 'Discussion' WHERE d.discussion_type != 'Document' AND da.id IS NOT NULL")
    for discussion in discussions
      discussion.destroy
      log.debug "Discussion with id:#{discussion.id} is deleted."
    end
  end

  #--
  #
  #Created on: 08/06/2012
  #Purpose:This method is used is used to fetch the discussions that should be visible to the users
  #++
  def visible_discussions(other_uid,page=1)
    per_page = 10
    off = (page-1)*per_page
    discussions = Discussion.find_by_sql(["SELECT DISTINCT d.*
			      FROM discussions d
            LEFT JOIN user_discussions u_d ON  d.id=u_d.discussion_id
            LEFT JOIN discussion_group_discussions dgd ON dgd.discussion_id=d.id
	          LEFT JOIN discussion_groups dg ON dg.id = dgd.discussion_group_id
            LEFT JOIN discussion_group_users dgu ON dgu.discussion_group_id = dg.id
            LEFT JOIN shared_tabs s_t ON s_t.shareable_id=d.id AND s_t.shareable_type='Discussion'
            LEFT JOIN groups g ON g.id=s_t.group_id
            LEFT JOIN group_users gu ON gu.group_id = g.id
            WHERE u_d.user_id=#{self.id} AND (((d.share_type='public') OR (d.share_type='groups' AND (gu.user_id=#{other_uid} OR dgu.user_id=#{other_uid})))) order by d.created_at DESC LIMIT ? OFFSET ?", per_page, off])
  end

  private
  def self.hash_password(p)
    Digest::SHA1.hexdigest("#{p}#{SECURITY_KEY}")
  end
end
