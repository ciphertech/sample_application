class UserDiscussion < ActiveRecord::Base
  belongs_to :user
  belongs_to :discussion

  after_create :send_email_to_followers

  #--
  #
  #Created on: 23/01/2012
  #Purpose:
  #++ This method is used to send an email to followers of user who marked email updates when user
  # add discussion.
  def send_email_to_followers
    followers = FollowerFollowing.where("following_id = ? AND get_email_updates = ?", self.user_id, true)
    discussion = self.discussion
    host = "www.convorum.com"
    for follower_following in followers
      Notifier.delay.mail_to_follower(follower_following, discussion,host)
    end
  end

end
