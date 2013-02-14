class Comment < ActiveRecord::Base
  require 'mechanize'
  acts_as_rateable
  belongs_to :user
  belongs_to :discussion
  has_many :images, :as => :imageable, :dependent => :destroy
  has_many :discussion_attachments, :as => :attachable, :dependent => :destroy
  has_many :ratings, :as => :rateable, :dependent => :destroy
  acts_as_tree :order => "comment"

  validates :comment,
    :presence => {:message => "can't be blank."},
    :length => {:maximum => 1000}, :unless => Proc.new { |comment| comment.comment_type == "Picture" }

  after_validation :check_picture_discussion

  def check_picture_discussion
    begin
      body = Mechanize.new.get(self.comment)
      self.errors.add :base, "Please enter a valid URL." if body.blank? || body.title.nil?
    rescue => e
      self.errors.add :base, "Please enter a valid URL."
    end if self.comment_type=="URL"
  end

  after_save :update_discussion
  before_save :add_title

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
  #Created on: 24/01/2012
  #++ This method is used to update the discussion updated_at whenever any comment is occur
  def update_discussion
    self.discussion.update_attribute(:updated_at, Time.now) if self.discussion
  end

  #--
  #
  #Created on: 24/01/2012
  #++ This method is used to add the title of a site to site url
  def add_title
    begin
      self.title = Mechanize.new.get(self.comment).title
    rescue => e
    end if self.comment_type == "URL"
  end

  def url_title
    self.title.blank? ? self.comment : self.title if self.comment_type=="URL"
  end

end
