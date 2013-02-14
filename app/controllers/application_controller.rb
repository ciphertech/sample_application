class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :get_username, :activerecord_error_list, :get_user_by_user_id

  #--                                                    
  #
  #Created on: 06/01/2012
  #Purpose: 
  #++ This method is used Througout the site (controller/views) to identify login user if present.
  def current_user
    session[:user]
  end

  #--                                                    
  #
  #Created on: 06/01/2012
  #Purpose: 
  #++ Check for user authentication.
  def login_required
    if session[:user]
      session[:back_url] = nil
      @login_user = User.find(session[:user])
    else
      session[:back_url] = request.request_uri if params[:action] == 'all_discussion' && params[:id].present?
      flash[:notice]='Please login to continue.'
      redirect_to :controller => "logins", :action=>"home" 
    end
  end

  #--                                                    
  #
  #Created on: 06/01/2012
  #Purpose: 
  #++ This method keeps admin away from restricted area
  def skip_for_admin
    if session[:user].is_admin?
      flash[:notice]='Sorry, this action is prohibited.'
      redirect_to :controller => "logins", :action=>"home" #TO_DO:- This should redirected to the Admin's Landing page
    end
  end

  #--                                                    
  #
  #Created on: 06/01/2012
  #Purpose: 
  #++ This method keeps user away from restricted area
  def skip_for_user
    if session[:user].is_user?
      flash[:notice]='Sorry, this action is prohibited.'
      redirect_to :controller => "users", :action => 'my_account'
    end
  end

  #--                                                    
  #
  #Created on: 09/01/2012
  #Purpose: 
  #++ This method is used to show Activercord errors in String (flash[:notice])
  #Ref:- http://snippets.dzone.com/posts/show/2348, Some code changes for Rails 3
  def activerecord_error_list(errors)
    error_list = ''
    errors.each_pair do |e, m|
      error_list += "#{m[0]}<br/> "
    end
    error_list
  end

  #--                                                    
  #
  #Created on: 30/06/2012
  #Purpose: 
  #++ This method is used to redirect user to home page if no post method is called
  def required_post_method
    redirect_to :controller => "logins", :action => "home" unless request.post?
  end

  #--
  #
  #Created on: 09/01/2012
  #Purpose:
  #++ This method to get a username
  def get_username(user_id)
    @username = User.find(:first, :conditions=>["id=?", user_id])
    @username.username
  end

  #--
  #
  #Created on: 13/01/2012
  #Purpose:
  #++ This method to get a user
  def get_user_by_user_id(user_id)
    @user = User.find(:first, :conditions=>["id=?", user_id])
    @user
  end

  #--                                                    
  #
  #Created on: 13/01/2012
  #Purpose: 
  #++ Check for user is present or not and redirect to current user profile if no user present.
  def other_user_check
    @other_user = User.find_by_id(params[:id])
    if !@other_user  || (@other_user.is_admin? && @login_user.is_user?)
      #flash[:notice]=''
      redirect_to "/users/profile/#{@login_user.id}"
    end
  end

  #--                                                    
  #
  #Created on: 16/01/2012
  #Purpose: 
  #++ User should redirected to Profile page if already login
  def already_login
    return true unless session[:user]
    #flash[:notice]='you are already logged in.'
    redirect_to "/users/profile/#{session[:user].id}"
  end





end
