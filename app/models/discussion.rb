class Discussion < ActiveRecord::Base
  require 'mechanize'
  acts_as_rateable
  has_many :user_discussions, :dependent => :destroy
  has_many :users, :through => :user_discussions
  has_many :ratings, :as => :rateable, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :discussion_attachments, :as => :attachable, :dependent => :destroy
  has_many :discussion_group_discussions, :dependent => :destroy
  has_many :html_contents, :dependent => :destroy
  has_many :images, :as => :imageable, :dependent => :destroy
  has_many :non_site_users, :as => :invitable, :dependent => :destroy
  has_many :discussion_groups, :through => :discussion_group_discussions

  scope :join_group, select("d.*").joins("d LEFT JOIN discussion_group_discussions dgd ON dgd.discussion_id=d.id")
  scope :group_share_type, lambda{ |id, type| where(["dgd.discussion_group_id=? and d.share_type=?", id, type]).order('dgd.created_at DESC') }
  
  validates_associated :user_discussions
  #ajaxful_rateable :stars => 10
  before_save :add_title
  after_create :save_web_content
  validates_format_of :discussion , :message => "Please enter a valid URL.", :with=> /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix , :if=>:url_validate
  validates_length_of :discussion , :maximum => 300 , :if=>:url_validate
  validates_length_of :discussion , :maximum => 1000 , :unless=>:url_validate
  #validates :discussion, :uniqueness=> true
  validates :title, :length => {:maximum => 150, :message => "Title can't be more than 150 characters."}
  after_validation :check_picture_discussion

  def check_picture_discussion
    self.errors.add :discussion, "can't be blank." if self.discussion_type != 'Picture' && self.discussion.blank?
  end

  #--                                                    
  #
  #Created on: 12/01/2012
  #Purpose: 
  #++ This method is used find the most popular discussions having comments between given period of time
  def self.most_popular(from, to,user_id,page=1,order_by_rating=false, group_id=nil,crowd_id=nil)
    per_page = 20
    off = (page-1)*per_page
    select = order_by_rating ? "(SUM(r.score)/COUNT(ra.id)) AS avg," : ""
    join=order_by_rating ? "LEFT JOIN ratings ra on d.id = ra.rateable_id AND 'Discussion' = ra.rateable_type LEFT JOIN rates r on ra.rate_id = r.id" : ""
    order = order_by_rating.nil? ? 'd.updated_at' : (order_by_rating ? "avg" : "count")
    date_query = " (d.updated_at>='#{from}' and d.updated_at<='#{to}') "
    crowd_user_ids = []
    user_ids = []
    crowd_user_ids = GroupUser.find(:all,:select => "user_id",:conditions=>["group_id=?",crowd_id]) if !crowd_id.nil?
    user_ids = crowd_user_ids.collect { |c_u|c_u.user_id  } if !crowd_user_ids.blank?
    user_ids << user_id unless group_id == '0' && crowd_id == '0'
    user_query = !user_ids.blank? ? (!crowd_id.nil? ? "and u_d.user_id in (#{user_ids.join(',')})" : "") : ""
    crowd_join = user_query!="" ? "LEFT JOIN user_discussions u_d ON u_d.discussion_id=d.id" : ""
    crow_cond = user_query!="" ? "OR (d.share_type!='public' AND gu.user_id=#{user_id})" : ""
    if user_id!=1
      group_members = DiscussionGroupUser.find(:all, :conditions => ['discussion_group_id=?', group_id], :select => user_id) if group_id != nil
      str, group_str = '', ''
      if group_id && group_id != "0"
        str =  " dg.id=#{group_id} AND "
        group_str = "OR (d.share_type='groups' AND dgu.user_id= #{user_id} )"
      end
      discussions = Discussion.find_by_sql(["SELECT #{select} COUNT(c.id) AS count, d.*
			      FROM discussions d LEFT JOIN comments c on d.id = c.discussion_id #{join}
            #{crowd_join}
            LEFT JOIN discussion_group_discussions dgd ON dgd.discussion_id = d.id
	          LEFT JOIN discussion_groups dg ON dg.id = dgd.discussion_group_id
            LEFT JOIN discussion_group_users dgu ON dgu.discussion_group_id = dg.id
            LEFT JOIN shared_tabs s_t ON s_t.shareable_id=d.id AND s_t.shareable_type='Discussion'
            LEFT JOIN group_users gu ON gu.user_id = #{user_id}
            LEFT JOIN groups g ON g.id=gu.group_id
            WHERE #{str} (((d.share_type='public') #{crow_cond}) #{group_str}) #{'AND' if date_query.present?} #{date_query} #{user_query} GROUP BY d.id ORDER BY #{order} DESC LIMIT ? OFFSET ?", per_page, off])
    else
      discussions = Discussion.find_by_sql(["SELECT #{select} COUNT(c.id) AS count, d.*
			      FROM discussions d LEFT JOIN comments c on d.id = c.discussion_id #{join}
	          WHERE #{date_query} GROUP BY d.id ORDER BY #{order} DESC LIMIT ? OFFSET ?", per_page, off])
    end
  end
  
  #--                                                    
  #
  #Created on: 13/01/2012
  #++ This method is used find the total votes for the discussion
  def votes
    self.ratings.length
  end

  #--                                                    
  #
  #Created on: 05/05/2012
  #++ This method is used to count the average ratings for each discussion
  def average_ratings
    ratings = 0
    self.ratings.each {|r| ratings += r.score}
    avg = votes == 0 ? 0 : ratings.to_f/votes.to_f
    "%.1f" % avg
  end

  #--                                                    
  #
  #Created on: 13/01/2012
  #++ This method is used find the array of the users ids for the discussion
  def user_ids
    self.users.collect{|ud| ud.id}
  end

  #--
  #
  #Created on: 03/05/2012
  #++ This method is used to count the total comments for each discussion
  def all_comments_count(discussion)
    Comment.count(:all, :conditions=>["discussion_id=?", discussion])
  end

  #--                                                    
  #
  #Created on: 23/01/2012
  #++ This method is used show the title of a site if present otherwise showing url itself
  def site_title
    self.title ? self.title : self.discussion
  end

  #--
  #
  #Created on: 22/02/2012
  #Purpose: to get all picture raters
  #++
  def raters
    users = User.raters(self.id, "Discussion")
  end

  
  #--
  #
  #Created on: 24/01/2012
  #++ This method is used to add the title of a site to site url
  def add_title
    begin
      self.title = Mechanize.new.get(self.discussion).title
    rescue => e
    end if self.discussion_type == "URL"
  end

  #--
  #
  #Created on: 14/05/2012
  #Purpose: to save html content for url
  #++
  def save_web_content
    begin
      body = Mechanize.new.get(self.discussion).body
      url_body = HtmlContent.create(:discussion_id=>self.id,:content=>body)
    rescue => e
    end if self.discussion_type == "URL"
  end

  #--
  #
  #Created on: 24/05/2012
  #Purpose: This method returns true false depend on user able to delete discussion or not
  #++
  def is_deletable?(user)
    user.is_admin? || (self.comments.blank? && self.user_discussions.first.user.id == user.id)
  end

  #--
  #
  #Created on: 02/06/2012
  #Purpose: This method returns true false depend on url for discussion is correct or not
  #++
  def self.is_valid_url?(url)
    begin
      body = Mechanize.new.get(url)
      valid = !(body.blank? || body.title.nil?)
    rescue => e
      valid = false
    end
    valid
  end

  #--
  #
  #Created on: 05/06/2012
  #Purpose: This method send an email to the non site crowd user
  #++
  def send_mails_to_non_site_crowd_user(login_user, host_port)
    crowds = SharedTab.select('group_id').where(["shareable_id=? AND shareable_type =?", self.id, 'Discussion'])
    groups = crowds.present? ? Group.find(:all, :conditions=>["id in (?)", crowds.map(&:group_id)]) : []
    for group in groups 
      for group_user in group.group_users
        user = group_user.user
        Notifier.delay.mail_to_crowd_user(user.email,login_user.username, self, host_port)
      end
      for non_site in group.non_site_members
        Notifier.delay.mail_to_nsu_on_disc(non_site.email, login_user.username, host_port, self,non_site.id)
      end
    end if groups.present?
  end

  def url_validate
    self.discussion_type == "URL"
  end

  
end
