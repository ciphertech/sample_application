class NonSiteUser < ActiveRecord::Base
  belongs_to :invitable, :polymorphic => true
  
  email_regex =  /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, :uniqueness => { :scope => [:invitable_id, :invitation_type], :message => 'Invitation already sent to this email.'},
                    :presence => { :message => "Email can't be blank." },
                    :length => { :maximum => 100, :message => "Email should not exceed 100 characters." },
                    :format => { :with => email_regex, :message => "Email is not valid." }
end
