class PhotoCommentObserver < ActiveRecord::Observer

  def after_save(photo_comment)
    Notifier.delay.mail_to_user_on_photo_comment(photo_comment) if photo_comment.discussable_type=="Picture" && photo_comment.user_id != photo_comment.discussable.album.user_id
  end

end
