class DiscussionGroupsController < ApplicationController
  before_filter :login_required
  #--
  #before_filter :other_user_check, :only => [:index]
  # GET /discussion_groups
  # GET /discussion_groups.xml
  #++
  def index
    @discussion_groups = @login_user.all_public_private_groups
    respond_to do |format|
      format.html # index.html.erb
      # format.xml  { render :xml => @discussion_groups }
    end
  end

  #--
  # GET /discussion_groups/1
  # GET /discussion_groups/1.xml
  #++
  def show
    @discussion_group = DiscussionGroup.find(params[:id])
    if @login_user.is_member_of_discussion_group(params[:id].to_i) || @discussion_group.is_public
      @discussions = @discussion_group.all_discussions
      respond_to do |format|
        format.html # show.html.erb
        #format.xml  { render :xml => @discussion_group }
      end
    else
      redirect_to @login_user.profile_path
    end
  end

  #--
  #
  #Created on: 14/04/2012
  #Purpose:
  #++ This method is used to save the multiple discussions in a specified group while multiple image uploading.
  def create_multiple_discussion
    host_port = request.host_with_port
    session[:current_images] = (0...8).map{65.+(rand(25)).chr}.join unless session[:current_images]
    @disc_error = @login_user.add_multiple_discussion?(params[:discussion],session[:current_images])
    if @disc_error.class.to_s == "Discussion" || @disc_error.class.to_s == "UserDiscussion"
      @discussion = @disc_error.class.to_s == "Discussion" ? @disc_error : @disc_error.discussion
      @message = "Discussion posted sucessfully."
    else
      @message = @disc_error
    end
    if !@discussion.nil?
      @message = "Discussion posted sucessfully."

      if @discussion.share_type == "groups"
        @dgd = DiscussionGroupDiscussion.new(:discussion_group_id=>params[:posted_to].to_i,:discussion_id=>@discussion.id)
        @message = @dgd.save ?  "Discussion posted sucessfully." : "Discussion already exists."
        group_members = @dgd.discussion_group.discussion_group_users.where("user_id!=#{@login_user.id}")
        group_members.each do |group_member|
          Notifier.delay.mail_to_group_member(group_member.user.email, @login_user.username, host_port, group_member.discussion_group.name, @discussion) unless @login_user.is_follower?(group_member.user_id)
        end if @dgd.save && @dgd.discussion_group.is_public == false

        @dgd.discussion_group.non_site_users.where(:invitation_type=>"Added").each do |group_member|
          NonSiteUser.create(:invitable_id=>@discussion.id, :invitable_type=>"Discussion", :invitation_type=>"Invited", :email=>group_member.email)
          Notifier.delay.mail_to_nsu_on_disc(group_member.email, @login_user.username, host_port, @discussion,group_member.id) if @dgd.discussion_group.is_public != true
          #Notifier.mail_to_private_group_user(group_member.email, @login_user.username, host_port, @dgd.discussion_group.name).deliver if @dgd.discussion_group.is_public != true
        end if @dgd.save && @dgd.discussion_group.is_public == false
      end
    end
      # @discuss = Discussion.new(:title => "title", :discussion => "discussion", :discussion_type => "Picture", :share_type => "#{session[:current_images]}")
      user_discussion =  @disc_error.user_discussions.build
      user_discussion.user_id = @login_user.id
      @picture =  @disc_error.images.build(:photo => params[:picture][:path], :details => "Discussion Picture", :user_id => @login_user.id)
      if @disc_error.save
        respond_to do |format|
          format.html {                                         #(html response is for browsers using iframe sollution)
            render :json => [@picture.to_jq_upload].to_json,
            :content_type => 'text/html',
            :layout => false
          }
          format.json {
            render :json => [@picture.to_jq_upload].to_json
          }
        end
      else
        render :json => [{:error => "custom_failure"}], :status => 304
      end
    end

  #--
  #
  #Created on: 03/04/2012
  #Purpose:
  #++ This method is used to create discussion
  def create_discussion
    host_port = request.host_with_port
    if params[:discussion] && params[:discussion][:discussion_type] == "URL" && !Discussion.is_valid_url?(params[:discussion][:discussion])
      @message = "Please enter a valid URL."
    else
      Discussion.transaction do
        @disc_error = @login_user.add_discussion?(params[:discussion])
        if @disc_error.class.to_s == "Discussion" || @disc_error.class.to_s == "UserDiscussion"
          @discussion = @disc_error.class.to_s == "Discussion" ? @disc_error : @disc_error.discussion
          @message = "Discussion posted sucessfully."
        else
          @message = @disc_error
        end
        #@discussion = @login_user.add_discussion?(params[:discussion])
        if !@discussion.nil?
          @message = "Discussion posted sucessfully."

          if @discussion.share_type == "groups"
            @dgd = DiscussionGroupDiscussion.new(:discussion_group_id=>params[:posted_to].to_i,:discussion_id=>@discussion.id)
            @message = @dgd.save ?  "Discussion posted sucessfully." : "Discussion already exists."
            group_members = @dgd.discussion_group.discussion_group_users.where("user_id!=#{@login_user.id}")
            group_members.each do |group_member|
              Notifier.delay.mail_to_group_member(group_member.user.email, @login_user.username, host_port, group_member.discussion_group.name, @discussion) unless @login_user.is_follower?(group_member.user_id)
            end if @dgd.save && @dgd.discussion_group.is_public == false

            @dgd.discussion_group.non_site_users.where(:invitation_type=>"Added").each do |group_member|
              NonSiteUser.create(:invitable_id=>@discussion.id, :invitable_type=>"Discussion", :invitation_type=>"Invited", :email=>group_member.email)
              Notifier.delay.mail_to_nsu_on_disc(group_member.email, @login_user.username, host_port, @discussion,group_member.id) if @dgd.discussion_group.is_public != true
              #Notifier.mail_to_private_group_user(group_member.email, @login_user.username, host_port, @dgd.discussion_group.name).deliver if @dgd.discussion_group.is_public != true
            end if @dgd.save && @dgd.discussion_group.is_public == false
          end
          if @message == "Discussion posted sucessfully."
            if params[:discussion][:discussion_type] == "Document"
              @attachment = params[:discussions][:attachment]
              disc_att = DiscussionAttachment.new(:file=> @attachment, :attachable_id => @discussion.id, :attachable_type => "Discussion")
              disc_att.save
              if !disc_att.save
                @message = activerecord_error_list(disc_att.errors)
                raise ActiveRecord::Rollback, "to roll back if file is not acceptable"
              end
            end

            if params[:discussion][:discussion_type] == "Picture"
              if params[:is_uploaded]!="false"
                @pic_attachment = params[:discussions][:attachment]
                disc_pic_att = Image.new(:photo => @pic_attachment, :imageable_id=>@discussion.id, :imageable_type => "Discussion", :details => "Discussion Picture")
                disc_pic_att.save
                if !disc_pic_att.save
                  @message = activerecord_error_list(disc_pic_att.errors)
                  raise ActiveRecord::Rollback, "to roll back if file is not acceptable"
                end
              else
                @photo = Image.new
                url = params[:photo_url]
                url_host = params[:added_from]
                @photo.site_url = url_host
                @photo.details= "Discussion Picture"
                @photo.imageable_id = @discussion.id
                @photo.imageable_type = "Discussion"
                @photo.upload_image(url)
                @photo.save
                if @photo.id.nil?
                  @message = @photo.errors[:photo][0]
                  raise ActiveRecord::Rollback, "to roll back if file is not acceptable"
                end
              end
            end
          end
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end

  #--
  #
  #Created on: 03/04/2012
  #Purpose: To create album
  #++
  def create_discussion_group
    @other_user=@login_user
    @discussion_groups = @login_user.discussion_groups
    @discussion_group = DiscussionGroup.new(:name => params[:discussion_group][:name], :user_id => @login_user.id, :description => params[:discussion_group][:description], :is_public => params[:discussion_group][:is_public])
    @notice = @discussion_group.save ? "Group created successfully.": activerecord_error_list(@discussion_group.errors)
    group_user = DiscussionGroupUser.create(:user_id=>@login_user.id,:discussion_group_id=>@discussion_group.id,:is_member=>true) if @discussion_group.save

    respond_to do |format|
      format.js
    end
  end

  #--
  #
  #Created on: 03/04/2012
  #Purpose: To edit album
  #++
  def edit_discussion_group
    if request.post?
      @discussion_group = DiscussionGroup.find(params[:disc_group][:id])
      @notice = @discussion_group.update_attributes(:name => params[:discussion_group][:name], :description => params[:discussion_group][:description], :is_public => params[:discussion_group][:is_public]) ? "Group updated successfully." : activerecord_error_list(@discussion_group.errors)
      #redirect_to :back
      respond_to do |format|
        format.js
      end
    else
      @discussion_group = DiscussionGroup.find(params[:id])
      render :partial => "edit_discussion_group"
    end
  end

  #--
  #
  #Created on: 03/04/2012
  #Purpose: To delete groups
  #++
  def delete_discussion_group
    @discussion_group = DiscussionGroup.find(params[:id])
    @discussion_group.destroy

    respond_to do |format|
      format.js
    end
  end

  #
  #Created on: 04/04/2012
  #Purpose:This method is used search public groups
  #++
  def search_groups
    @search_text = params[:search_text]
    @discussion_groups = @login_user.find_public_groups(params[:search_text], 1) if !params[:search_text].nil?
  end

  #
  #Created on: 04/04/2012
  #Purpose:This method is used load more search result on scroll
  #++
  def load_more_groups
    @search_text = params[:search_text]
    @discussion_groups = @login_user.find_public_groups(params[:search_text], params[:page].to_i)
  end

  #--
  #
  #Created on: 03/04/2012
  #Modified by: Jalendra
  #Modified Date: 06/15/12
  #Purpose: To delete groups
  #++
  def add_user_to_groups
    host_port = request.host_with_port
    @discussion_group = DiscussionGroup.find(params[:id])
    @non_site_user_emails = params[:add_user_to_groups][:email].split(',')
    if @non_site_user_emails.include?(@login_user.email)
      @notice = "Can't sent a invitation to yourself."
    else
      @non_site_user_emails.each do |emails|
        nsu = NonSiteUser.new(:invitable_id=>@discussion_group.id, :invitable_type=>"DiscussionGroup", :invitation_type=>"Added", :email=>  emails.gsub(/\s+/, ""))
        @added = true if nsu.save
      end if @non_site_user_emails
    end
    @notice = @notice ? @notice : (@added ? "User added successfully." : "User is already added.")
    respond_to do |format|
      format.js
    end
  end

  #--
  #
  #Created on: 03/04/2012
  #Purpose: To Send a invitation by emails, by usernames, by groups
  #++
  def invite_user_to_groups
    host_port = request.host_with_port
    @discussion_group = DiscussionGroup.find(params[:id])
    if params[:invite_to] == "by_email"
      @non_site_user_emails = params[:invite_user_to_groups][:email].split(',')
      if @non_site_user_emails.include?(@login_user.email)
        @notice = "Can't sent a invitation to yourself."
      else
        @non_site_user_emails.each do |emails|
          user = User.find_by_email(emails)
          if !user.nil?
            disc_group_user = DiscussionGroupUser.new(:discussion_group_id => @discussion_group.id, :user_id => user.id, :is_member => 0)
            @notice = disc_group_user.save ? "Invitation successfully sent." : activerecord_error_list(disc_group_user.errors)
            Notifier.delay.mail_to_private_group_user(user.email, @discussion_group.user.username, host_port, @discussion_group.name) if disc_group_user.save
          else
            private_group_user = NonSiteUser.new(:email => emails.gsub(/\s+/, ""), :invitable_id => @discussion_group.id, :invitable_type => "DiscussionGroup")
            @notice = private_group_user.save ? "Invitation successfully sent." : activerecord_error_list(private_group_user.errors)
            Notifier.delay.mail_to_non_site_user(private_group_user.email, @discussion_group.user.username, host_port, @discussion_group.name, private_group_user.id) if private_group_user.save
          end
        end if @non_site_user_emails
      end
    end

    if params[:invite_to] == "by_username"
      @usernames = params[:invite_user_to_groups][:username]
      @usernames = @usernames.split(", ") if @usernames
      user_ids = Array.new
      @usernames.each do |user|
        user_ids = User.find(:first, :conditions=>["username=?", user])
        if !user_ids.blank?
          disc_group_user = DiscussionGroupUser.new(:discussion_group_id => @discussion_group.id, :user_id => user_ids.id, :is_member => 0)
          @notice = disc_group_user.save ? "Invitation successfully sent." : activerecord_error_list(disc_group_user.errors)
          Notifier.delay.mail_to_private_group_user(user_ids.email, @discussion_group.user.username, host_port, @discussion_group.name) if disc_group_user.save
        else
          @notice = "Username does not exists!"
        end
      end if @usernames
    end

    if params[:invite_to] == "by_group"
      @groups = params[:invite_user_to_groups][:groups]
      @groups = @groups.split(", ") if @groups
      user_ids = Array.new
      @groups.each do |group|
        group_ids = DiscussionGroup.find(:first, :conditions=>["name=?", group])
        if !group_ids.blank?
          user_ids = DiscussionGroupUser.find(:all, :conditions=>["discussion_group_id=? AND is_member=? AND user_id !=?", group_ids.id, true, @login_user.id])
          user_ids.each do |u_id|
            disc_group_user = DiscussionGroupUser.new(:discussion_group_id => @discussion_group.id, :user_id => u_id.user_id, :is_member => 0)
            @notice = disc_group_user.save ? "Invitation successfully sent." : activerecord_error_list(disc_group_user.errors)
            Notifier.delay.mail_to_private_group_user(u_id.user.email, @discussion_group.user.username, host_port, @discussion_group.name) if disc_group_user.save
          end if user_ids
        else
          @notice = "Group does not exists!"
        end
      end if @groups
    end

    respond_to do |format|
      format.js
    end
  end

  #--
  #
  #Created on: 06/04/2012
  #Purpose: To Send a invitation by emails, by usernames, by groups
  #++
  def notifications
    @other_user = @login_user
    @notifications = DiscussionGroupUser.where(['user_id =? AND is_member=?', @login_user.id, false])
    @disc_notifications = NonSiteUser.where(["email=? AND invitable_type=? and invitation_type=?",@login_user.email,"Discussion","Invited"])
    respond_to do |format|
      format.html
    end
  end

  #--
  #
  #Created on: 06/04/2012
  #Purpose: To Send a invitation by emails, by usernames, by groups
  #++
  def accept_invitation
    if params[:type] && params[:type]=="Discussion"
      @nsu = NonSiteUser.find(params[:id])
      @disc = Discussion.find(@nsu.invitable_id)
      @ud = UserDiscussion.create(:user_id=>@login_user.id, :discussion_id=>@disc.id) if !@login_user.is_discussed?(@disc.id)
      @notice = @ud && @ud.save && @nsu.destroy ? "You have joined discussion successfully." : "Could not join discussion."
    else
      @accept = DiscussionGroupUser.find(params[:id])
      @notice = @accept.update_attribute(:is_member, true)
    end

    respond_to do |format|
      format.js
    end
  end

  #--
  #
  #Created on: 06/04/2012
  #Purpose: To Send a invitation by emails, by usernames, by groups
  #++
  def decline_invitation
    @accept = params[:type] && params[:type]=="Discussion" ? NonSiteUser.find(params[:id]) : DiscussionGroupUser.find(params[:id])
    @accept.destroy
    respond_to do |format|
      format.js
    end
  end

  #--
  #
  #Created on: 06/04/2012
  #Purpose: To Send a invitation by emails, by usernames, by groups
  #++
  def join_group
    @disc_group = DiscussionGroup.find(params[:id])
    @join = DiscussionGroupUser.new(:discussion_group_id => @disc_group.id, :user_id => @login_user.id, :is_member => 1)
    if @join.save
      respond_to do |format|
        format.js
      end
    else
      render :text=>"Fail"
    end
  end

  #--
  #
  #Created on: 06/04/2012
  #Purpose: To unjoined the groups that joined by login user
  #++
  def unjoin_group
    @disc_group = DiscussionGroup.find(params[:id])
    @unjoin = DiscussionGroupUser.find(:last, :conditions =>["discussion_group_id=? AND user_id=? AND is_member=?", @disc_group.id, @login_user.id, 1])
    if @unjoin.destroy

      respond_to do |format|
        format.js
      end
    else
      render :text=>"Fail"
    end
  end

  #--
  #
  #Created on: 06/04/2012
  #Purpose: To unjoined the groups that joined by login user
  #++
  def leave_joined_group
    @disc_group = DiscussionGroup.find(params[:id])
    @unjoin = DiscussionGroupUser.find(:last, :conditions =>["discussion_group_id=? AND user_id=? AND is_member=?", @disc_group.id, @login_user.id, 1])
    if @unjoin.destroy
      respond_to do |format|
        format.js
      end
    else
      render :text=>"Fail"
    end
  end

  #--
  #
  #Created on: 09/05/2012
  #Purpose: To display images in discussion group album
  #++
  def group_album
    @discussion_group = DiscussionGroup.find(params[:id])
    if @login_user.is_member_of_discussion_group(params[:id].to_i) || @discussion_group.is_public
      @pictures = Image.find_by_sql(["SELECT DISTINCT i.* FROM discussion_group_discussions dgd
					 LEFT JOIN discussions d on dgd.discussion_id = d.id
					 LEFT JOIN comments c on dgd.discussion_id = c.discussion_id
					 LEFT JOIN images i ON (imageable_id = dgd.id AND imageable_type = 'DiscussionGroup')
					      OR (imageable_id = d.id AND imageable_type = 'Discussion')
					      OR (imageable_id = c.id AND imageable_type = 'Comment')
 					WHERE i.id IS NOT NULL  AND dgd.discussion_group_id =? ",params[:id].to_i])
    else
      redirect_to @login_user.profile_path
    end
  end

  #--
  #
  #Created on: 11/02/2012
  #Purpose: add photo options
  #++
  def add_photo
    @current_discussion_id = params[:group_discussion_id].to_i
    if @login_user.is_member_of_discussion_group(@current_discussion_id) && (params[:photo_url])
      url = params[:photo_url]
      url_host = params[:added_from]
      @photo = Image.new(:details => params[:photo_detail], :site_url => url_host, :imageable_id => @current_discussion_id, :imageable_type => "DiscussionGroup", :user_id => current_user.id)
      @photo.upload_image(url)
      @photo.save
    end
    respond_to do |format|
      format.js
    end
  end

  #--
  #
  #Created on: 15/02/2012
  #Purpose: add photo from system
  #++
    def add_photo_from_system
    @photo = Image.new(params[:photos])
    @photo.imageable_type = "DiscussionGroup"
    @photo.user_id = current_user.id
    if @login_user.is_member_of_discussion_group(params[:photos][:imageable_id].to_i) && @photo.save
      flash[:notice] = "Photo added successfully."
    end
    flash[:notice] = @photo.errors.first[1] if !@photo.errors.blank?
    redirect_to :back

  end

  #--
  #
  #Created on: 16/02/2012
  #Purpose: load discussion photos on scrolling page(ajax)
  #++
  def load_pictures
    page = params[:page].to_i
    per_page = 20
    off = (page-1)*per_page
    @discussion_group = DiscussionGroup.find(params[:id])
    @pictures = @discussion_group.images.offset(off).limit(10).order("photo_updated_at DESC ")
  end

  #--
  #
  #Created on: 15/02/2012
  #Purpose: to like the photo
  #++
  def like_picture
    @like = Like.new(:user_id=>@login_user.id,:likable_id=>params[:id],:likable_type=>"Image")
    @pic = Image.find(params[:id])
    if @like.save
      respond_to do |format|
        format.js
      end
    else
      render :text=>"Fail"
    end
  end

  #--
  #
  #Created on: 15/02/2012
  #Purpose: to like the photo
  #++
  def unlike_picture
    @pic = Image.find(params[:id])
    @like = Like.where(["user_id=? AND likable_id=? AND likable_type=?", @login_user.id, params[:id], "Image"])
    if @like.destroy
      respond_to do |format|
        format.js
      end
    else
      render :text=>"Fail"
    end
  end

  #--
  #
  #Created on: 15/02/2012
  #Purpose: load full details of photo
  #++
  def load_photo_full_detail
    @picture = Image.find(params[:id])
    render :partial=>"discussion_groups/image_partials/photo_full_detail", :locals=>{:pic=>@picture}
  end

  #--
  #
  #Created on: 15/02/2012
  #Purpose: post comment
  #++
  def post_photo_comment
    @pic = Image.find(params[:image_id].to_i)
    @comment = PhotoComment.new(:comment=>params[:comment],:user_id=>@login_user.id,:discussable_id=>params[:image_id],:discussable_type=>"Image")
    if @comment.save
      respond_to do |format|
        format.js
      end
    else
      render :text => "Fail"
    end
  end

  #--
  #
  #Created on: 16/02/2012
  #Purpose: delete comment
  #++
  def delete_picture_comment
    @comm = PhotoComment.find(params[:id])
    @pic = Image.find(@comm.discussable_id)
    if [@pic.user_id, @comm.user_id].include?(@login_user.id)
      if @comm.destroy
        respond_to do |format|
          format.js
        end
      else
        render :text=>"Fail"
      end
    else
      render :text=>"Not your photo"
    end
  end

  #--
  #
  #Created on: 15/02/2012
  #Purpose: delete picture
  #++
  def delete_picture
    @pic = Image.find(params[:id])
    if @login_user.is_member_of_discussion_group(@pic.imageable_id) && [@pic.user_id, @pic.imageable.user_id].include?(@login_user.id)
      render :text=> @pic.destroy ? "Success" : "Fail"
    else
      render :text=>"Not your photo"
    end
  end

  #--
  #
  #Created on: 16/02/2012
  #Purpose: delete comment
  #++
  def import_picture
    if request.post?
      render :text=>"Nothing to do"
    else
      @pic= Image.find(params[:id])
      @photo_url = "http://"+request.host_with_port + @pic.photo(:original)
      @album = Album.find(:all,:conditions=>["user_id=?",@login_user.id])
      render :partial=>"albums/import_picture"
    end
  end


  #
  #Created on: 05/05/2012
  #Purpose:
  #++ This method is used load discussions in group
  def load_group_discussions_on_scroll
    @discussion_group = DiscussionGroup.find(params[:id])
    if @login_user.is_member_of_discussion_group(params[:id].to_i) || @discussion_group.is_public
      @discussions = @discussion_group.all_group_discussions(params[:page].to_i)
      render :partial => "discussion_groups_discussion_block", :locals => {:discussions => @discussions }
    end
  end

  #
  #Created on: 06/09/2012
  #Purpose:
  #++ This method is used to import the gmail contacts by providing gmail credentails
  def import_gmail_contacts
    @group = DiscussionGroup.find(params[:id])
    if @login_user.is_member_of_discussion_group(@group.id)
      if request.post?
        begin
          @contacts = Contacts::Gmail.new(params[:email], params[:password]).contacts
          @contacts.each{|c| c[0] = c[1] if c[0].blank? }
          @contacts = @contacts.sort{|a,b| a[0].nil? ? -1 : b[0].nil? ? 1 : a[0].downcase <=> b[0].downcase }
        rescue Exception => e
          @message = e.message == "Username or password are incorrect" ? "Username or password is incorrect." : e.message
        end
        respond_to do |format|
          format.js
        end
      else
        respond_to do |format|
          format.html { render :layout => false}
        end
      end
    else
      flash[:notice] = "You can not invite the user in this group."
      redirect_to :back
    end
  end

  #
  #Created on: 06/09/2012
  #Purpose:
  #++ This method is used to send invitations to the email ids in group.
  def invite_emails_to_group
    @emails = params[:user][:email] if  !params[:user].blank?
    host_port = request.host_with_port
    @group = DiscussionGroup.find(params[:group][:id])
    for email in @emails
      user = User.find_by_email(email)
      if !user.nil?
        disc_group_user = DiscussionGroupUser.new(:discussion_group_id => @group.id, :user_id => user.id, :is_member => 0)
        @notice = disc_group_user.save ? "Invitation successfully sent." : activerecord_error_list(disc_group_user.errors)
        @added = true if !disc_group_user.id.nil?
        Notifier.delay.mail_to_private_group_user(user.email, @group.user.username, host_port, @group.name) if disc_group_user.save
      else
        private_group_user = NonSiteUser.new(:email => email.gsub(/\s+/, ""), :invitable_id => @group.id, :invitable_type => "DiscussionGroup", :invitation_type=>"Invited")
        @notice = private_group_user.save ? "Invitation successfully sent." : activerecord_error_list(private_group_user.errors)
        @added = true if !private_group_user.id.nil?
        Notifier.delay.mail_to_non_site_user(private_group_user.email, @group.user.username, host_port, @group.name, private_group_user.id) if private_group_user.save
      end
    end if !@emails.blank?
    flash[:notice] = "Invitation successfully sent." if @added
  end

  #
  #Created on: 06/15/2012
  #Purpose:
  #++ This method is used to delete the added email to the private groups
  def delete_added_group_user
    @nsu = NonSiteUser.find(params[:id])
    @group = DiscussionGroup.find(@nsu.invitable_id) if @nsu.invitable_type=="DiscussionGroup" && @nsu.invitation_type=="Added"
    @message = @group && !@group.is_public ? ( @nsu.destroy ? "Success" : nil) : "Failure"
    respond_to do |format|
      format.js   { render :text => @message }
    end
  end

  #
  #Created on: 06/15/2012
  #Purpose:
  #++ This method is used to edit the added email to the private groups
  def edit_added_group_user
    @nsu = NonSiteUser.find(params[:id])
    if request.post?
      old = @nsu.email
      if old != params[:nsu][:email]
        @added = true if @nsu.update_attributes(:email=> params[:nsu][:email])
        @notice = @added ? "Email updated successfully." : "Email is already added."
        @discussion_group = DiscussionGroup.find(@nsu.invitable_id)
      else
        @notice = "Nothing to update."
      end
      render 'add_user_to_groups', :format => :js
    else
      respond_to do |format|
        format.html { render :layout => false}
      end
    end
  end

end


#SCAFFOLDING CODE
# GET /discussion_groups/new
# GET /discussion_groups/new.xml
#  def new
#    @discussion_group = DiscussionGroup.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @discussion_group }
#    end
#  end

# GET /discussion_groups/1/edit
#  def edit
#    @discussion_group = DiscussionGroup.find(params[:id])
#  end

# POST /discussion_groups
# POST /discussion_groups.xml
#  def create
#    @discussion_group = DiscussionGroup.new(params[:discussion_group])
#
#
#    respond_to do |format|
#      if @discussion_group.save
#
#        format.html { redirect_to(@discussion_group, :notice => 'Discussion group was successfully created.') }
#        format.xml  { render :xml => @discussion_group, :status => :created, :location => @discussion_group }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @discussion_group.errors, :status => :unprocessable_entity }
#      end
#    end
#  end

# PUT /discussion_groups/1
# PUT /discussion_groups/1.xml
#  def update
#    @discussion_group = DiscussionGroup.find(params[:id])
#
#    respond_to do |format|
#      if @discussion_group.update_attributes(params[:discussion_group])
#        format.html { redirect_to(@discussion_group, :notice => 'Discussion group was successfully updated.') }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @discussion_group.errors, :status => :unprocessable_entity }
#      end
#    end
#  end

# DELETE /discussion_groups/1
# DELETE /discussion_groups/1.xml
#  def destroy
#    @discussion_group = DiscussionGroup.find(params[:id])
#    @discussion_group.destroy
#
#    respond_to do |format|
#      format.html { redirect_to(discussion_groups_url) }
#      format.xml  { head :ok }
#    end
#  end
