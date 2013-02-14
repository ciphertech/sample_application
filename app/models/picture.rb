require 'mime/types'
class Picture < ActiveRecord::Base
  acts_as_rateable
  require 'open-uri'
  has_many :likes, :as => :likable, :dependent => :destroy
  has_many :photo_comments, :as => :discussable, :dependent => :destroy
  belongs_to :album
  has_many :ratings, :as => :rateable, :dependent => :destroy
  
  has_attached_file :photo, :path => ":rails_root/public/albums/photos/:id/:style_:basename.:extension",
    :url => "/albums/photos/:id/:style_:basename.:extension",
    :styles => {
    :small  => "50x50#",
    :medium=> "190x" }, :whiny => false

  validates :photo_detail,:presence=>{:message=>"Photo detail can't be blank."}, :length=>{:maximum=>500, :message=>"Photo detail can't be more than 500 characters."}
  validates_attachment_size  :photo, :less_than => 10.megabytes, :message => "Please select picture upto 10MB file size."
  validates_attachment_content_type :photo, :content_type =>['image/jpeg','image/pjpeg', 'image/png','image/x-png', 'image/bmp', 'image/jpg'], :message => "Please uplaod file of format .jpg, .png, .bmp, .jpeg."
  validates_attachment_presence :photo, :message => "Please choose a file to upload."

  before_create :normalize_file_name

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
      self.save#(false)
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
    Like.find(:all,:conditions=>["user_id=? and likable_id=? and likable_type=?",u_id,self.id,'Picture']).present?
  end

  #--
  #
  #Created on: 15/02/2012
  #Purpose: to get all picture likers
  #++
  def likers
    users = User.find_by_sql(["SELECT u.* FROM (likes l LEFT JOIN users u ON l.user_id=u.id)
                          WHERE l.likable_id=? and l.likable_type=?",self.id,"Picture" ])
  end

  #--
  #
  #Created on: 15/02/2012
  #Purpose: to get like count of picture
  #++
  def like_count
    Like.count(:conditions=>["likable_id=? and likable_type=?",self.id,"Picture"])
  end

  #--
  #
  #Created on: 15/02/2012
  #Purpose: to get comment count of picture
  #++
  def comment_count
    PhotoComment.count(:conditions=>["discussable_id=? and discussable_type=?",self.id,"Picture"])
  end

  #--
  #
  #Created on: 22/02/2012
  #Purpose: to get top 5 comments
  #++
  def top_five_comments
    PhotoComment.find(:all,:conditions=>["discussable_id=? and discussable_type=?",self.id,"Picture"],:limit=>5,:order=>"created_at DESC")
  end

  #--                                                    
  #
  #Created on: 15/05/2012
  #Reviewed by: Salil Gaikwad
  #Reviewed on: 28/06/2012
  #++ This method is used find the total votes for the picture
  def votes
    self.ratings.length
  end

  #--                                                    
  #
  #Created on: 15/05/2012
  #Reviewed by: Salil Gaikwad
  #Reviewed on: 28/06/2012
  #++ This method is used to count the average ratings for each picture
  def average_ratings
    ratings, vote_count = 0, votes
    self.ratings.each {|r| ratings += r.score}
    avg = vote_count == 0 ? 0 : ratings.to_f/vote_count.to_f
    "%.1f" % avg
  end

  #--
  #
  #Created on: 15/05/2012
  #Purpose: to get all picture raters
  #++
  def raters
    users = User.raters(self.id, "Picture")
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
