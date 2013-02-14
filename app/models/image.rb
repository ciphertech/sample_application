require 'mime/types'
class Image < ActiveRecord::Base
  require 'open-uri'
  has_many :likes, :as => :likable, :dependent => :destroy
  has_many :photo_comments, :as => :discussable, :dependent => :destroy
  belongs_to :user
  belongs_to :imageable, :polymorphic => true

  has_attached_file :photo, :path => ":rails_root/public/discussion_images/:id/:style_:basename.:extension",
    :url => "/discussion_images/:id/:style_:basename.:extension",
    :styles => {
    :small  => "50x50#",
    :medium=> "190x" }, :whiny => false

  #validates :details,:presence=>{:message=>"Photo detail can't be blank."}, :length=>{:maximum=>500, :message=>"Photo detail can't be more than 500 characters."}
  validates_attachment_size  :photo, :less_than => 10.megabytes, :message => "Please select picture upto 10MB file size."
  validates_attachment_content_type :photo, :content_type =>['image/jpeg','image/pjpeg', 'image/png','image/x-png', 'image/bmp', 'image/jpg'], :message => "Please uplaod file of format .jpg, .png, .bmp, .jpeg."
  validates_attachment_presence :photo, :message => "Please choose a file to upload."

  before_save :normalize_file_name

  #one convenient method to pass jq_upload the necessary information
  def to_jq_upload
    {
      "name" => read_attribute(:photo),
      "size" => photo.size,
      "url" => photo.url,
      "thumbnail_url" => photo(:small),
      "delete_type" => "DELETE"
    }
  end
  
  def upload_image(url)
    begin
      io = open(URI.escape(url))
      if io
        def io.original_filename; base_uri.path.split('/').last; end
        io.original_filename.blank? ? nil : io
        self.photo = io
      end
      #self.save#(false)
    rescue Exception => e
      logger.info "EXCEPTION# #{e.message}"
    end
  end

  #--
  #
  #Created on: 15/02/2012
  #Purpose: to get if picture is liked or not
  #++
  def is_liked_by(u_id)
    Like.find(:all,:conditions=>["user_id=? and likable_id=? and likable_type=?",u_id,self.id,'Image']).present?
  end

  #--
  #
  #Created on: 15/02/2012
  #Purpose: to get all picture likers
  #++
  def likers
    users = User.find_by_sql(["SELECT u.* FROM (likes l LEFT JOIN users u ON l.user_id=u.id)
                          WHERE l.likable_id=? and l.likable_type=?",self.id,"Image" ])
  end

  #--
  #
  #Created on: 15/02/2012
  #Purpose: to get like count of picture
  #++
  def like_count
    Like.count(:conditions=>["likable_id=? and likable_type=?",self.id,"Image"])
  end

  #--
  #
  #Created on: 15/02/2012
  #Purpose: to get comment count of picture
  #++
  def comment_count
    PhotoComment.count(:conditions=>["discussable_id=? and discussable_type=?",self.id,"Image"])
  end

  
  def pic_user 
    if self.imageable_type == 'DiscussionGroup'
      self.user
    elsif self.imageable_type == 'Discussion'
      self.imageable.user_discussions.first.user
    elsif self.imageable_type == 'Comment'
      self.imageable.user
    end
  end

  #--
  #
  #Created on: 22/02/2012
  #Purpose: to get top 5 comments
  #++
  def top_five_comments
    PhotoComment.find(:all,:conditions=>["discussable_id=? and discussable_type=?",self.id,"Image"],:limit=>5,:order=>"created_at DESC")
  end

  #for normalize the file name while uploading the photo(remove spaces)
  private
  def normalize_file_name
    self.instance_variable_get(:@_paperclip_attachments).keys.each do |attachment|
      attachment_file_name = (attachment.to_s + '_file_name').to_sym
      if self.send(attachment_file_name)
        self.send(attachment).instance_write(:file_name, self.send(attachment_file_name).gsub(/ /,'_'))
      end
    end
  end
end
