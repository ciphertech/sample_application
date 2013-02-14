require 'mime/types'
class DiscussionAttachment < ActiveRecord::Base
  belongs_to :attachable , :polymorphic => true
  has_attached_file :file, :path => ":rails_root/public/discussion_attachment/:id/:style_:basename.:extension",
    :url => "/discussion_attachment/:id/:style_:basename.:extension",
    :whiny => false
  #validates :description,:presence=>{:message=>"Description can't be blank."}, :length=>{:maximum=>100, :message=>"Description can't be more than 500 characters."}
  validates_attachment_size  :file, :less_than => 5.megabytes, :message => "Please select file upto 5MB file size."
  validates_attachment_content_type :file, :content_type =>['application/pdf','application/doc','application/msword'], :message => "Please uplaod file of format .pdf or .doc format."
  #validates_format_of :file_file_name, :with => %r{\.(docx|doc|pdf)$}i
  validates_attachment_presence :file, :message => "Please choose a file to upload."
end
