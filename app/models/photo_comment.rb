class PhotoComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :discussable, :polymorphic => true

  validates :comment, :presence => {:message => "Comment can't be blank."}
  validates :comment, :length => {:maximum => 1000, :message => "Maximum 1000 characters are allowed."}
end
