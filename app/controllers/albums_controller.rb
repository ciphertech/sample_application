class AlbumsController < ApplicationController
  require 'uri'
  before_filter :login_required#, :except =>[:find_photo]
  before_filter :other_user_check, :only => [:index]
  # GET /albums
  # GET /albums.xml
  def index
    @albums = @other_user.shared_albums(@login_user.id)
  end

  # GET /albums/1
  # GET /albums/1.xml
  def show
    @album = Album.find(:all,:conditions=>["user_id=?",@login_user.id])
    @curr_album = Album.find(params[:id])
    #@pictures = Picture.find(:all,:conditions=>["album_id=?",params[:id]])
    #@pictures = @curr_album.shared_pictures(@login_user.id)
    @pictures = @curr_album.shared_pictures(@login_user.id,1)
    @is_current_user = @other_user
    respond_to do |format|
      format.html 
    end
  end


  #--
  #
  #Created on: 13/02/2012
  #Purpose: To create album
  #++
  def create_album
    @other_user=@login_user
    @albums = @login_user.albums
    @album = Album.new(:name=>params[:album][:name], :user_id=>@login_user.id, :share_type => 0)
    @notice = @album.save ? "Album created successfully.": activerecord_error_list(@album.errors)

    respond_to do |format|
      format.js
    end
  end

  #--
  #
  #Created on: 13/02/2012
  #Purpose: To delete album
  #++
  def delete_album
    @album = Album.find(params[:id])
    @album.destroy
     
    respond_to do |format|
      format.js
    end
  end

  #--
  #
  #Created on: 13/02/2012
  #Purpose: To edit album
  #++
  def edit_album
    @album = Album.find(params[:album][:id])
    @notice = @album.update_attributes(:name=> params[:album][:name]) ? "Album name updated successfully." : activerecord_error_list(@album.errors)
    #redirect_to :back
    respond_to do |format|
      format.js
    end
  end


  #--
  #
  #Created on: 14/02/2012
  #Purpose:This method is used to set album as public
  #++
  def share_album_in_group
    if request.post?
      @group_ids = params[:group_ids]
      @album = Album.find(params[:album_id])
      if params[:photos][:share_type].to_i == 2
        @pre_group_ids = Array.new
        @login_user.groups_having_album_shared(params[:album_id]).each do |g|
          @pre_group_ids<< g.id
        end if !@login_user.groups_having_album_shared(params[:album_id]).blank?

        @pre_group_ids.each do |g_id|
          SharedTab.delete_all("shareable_id=#{@album.id} AND shareable_type='#{@album.class.to_s}' AND group_id=#{g_id}") if g_id and !@group_ids.include?(g_id)
        end if !@pre_group_ids.blank? and !@group_ids.blank?

        @group_ids.each do |g_id|
          SharedTab.create(:shareable_id => params[:album_id].to_i, :shareable_type => @album.class.to_s, :group_id => g_id)
        end if !@group_ids.blank?
        if(@group_ids.blank?)
          flash[:notice]="At least one group must be selected to share the album."
        end
      else
        SharedTab.delete_all("shareable_id=#{@album.id} AND shareable_type='#{@album.class.to_s}'")
      end
      @album.update_attribute(:share_type, params[:photos][:share_type].to_i)
      flash[:notice]="#{@album.name} album shared successfully." if params[:photos][:share_type].to_i == 2
      flash[:notice]="#{@album.name} album is set to public." if params[:photos][:share_type].to_i == 0
      flash[:notice]="#{@album.name} album is set to private." if params[:photos][:share_type].to_i == 1
      redirect_to :back
    else
      @album = Album.find(params[:id])
      render :partial=>"share_album_with_group", :locals=>{:album=>@album}, :layout=>false
    end
  end

  #--
  #
  #Created on: 14/02/2012
  #Purpose:This method is used to set photo as public
  #++
  def share_photo_in_group
    if request.post?
      @group_ids = params[:group_ids]
      @picture = Picture.find(params[:pic_id])
      if params[:photos][:share_type].to_i == 2
        @pre_group_ids = Array.new
        @login_user.groups_having_photo_shared(params[:id]).each do |g|
          @pre_group_ids<< g.id
        end if !@login_user.groups_having_photo_shared(params[:id]).blank?

        @pre_group_ids.each do |g_id|
          SharedTab.delete_all("shareable_id=#{@picture.id} AND shareable_type='#{@picture.class.to_s}' AND group_id=#{g_id}") if g_id and !@group_ids.include?(g_id)
        end if !@pre_group_ids.blank? and !@group_ids.blank?

        @group_ids.each do |g_id|
          SharedTab.create(:shareable_id => params[:pic_id].to_i, :shareable_type => @picture.class.to_s, :group_id => g_id)
        end if !@group_ids.blank?
        if(@group_ids.blank?)
          flash[:notice]="At least one group must be selected to share the album."
        end
      else
        SharedTab.delete_all("shareable_id=#{@picture.id} AND shareable_type='#{@picture.class.to_s}'")
      end
      @picture.update_attribute(:share_type, params[:photos][:share_type].to_i)
      flash[:notice]="Picture shared successfully." if params[:photos][:share_type].to_i == 2
      flash[:notice]="Picture is set to public." if params[:photos][:share_type].to_i == 0
      flash[:notice]="Picture is set to private." if params[:photos][:share_type].to_i == 1
      redirect_to :back
    else
      @picture = Picture.find(params[:id])
      render :partial=>"share_photo_with_group", :locals=>{:picture=>@picture}, :layout=>false
    end
  end


  # GET /albums/new
  # GET /albums/new.xml
  #  def new
  #    @album = Album.new
  #
  #    respond_to do |format|
  #      format.html # new.html.erb
  #      format.xml  { render :xml => @album }
  #    end
  #  end

  # GET /albums/1/edit
  #  def edit
  #    @album = Album.find(params[:id])
  #  end

  # POST /albums
  # POST /albums.xml
  #  def create
  #    @album = Album.new(params[:album])
  #
  #    respond_to do |format|
  #      if @album.save
  #        format.html { redirect_to(@album, :notice => 'Album was successfully created.') }
  #        format.xml  { render :xml => @album, :status => :created, :location => @album }
  #      else
  #        format.html { render :action => "new" }
  #        format.xml  { render :xml => @album.errors, :status => :unprocessable_entity }
  #      end
  #    end
  #  end

  # PUT /albums/1
  # PUT /albums/1.xml
  #  def update
  #    @album = Album.find(params[:id])
  #
  #    respond_to do |format|
  #      if @album.update_attributes(params[:album])
  #        format.html { redirect_to(@album, :notice => 'Album was successfully updated.') }
  #        format.xml  { head :ok }
  #      else
  #        format.html { render :action => "edit" }
  #        format.xml  { render :xml => @album.errors, :status => :unprocessable_entity }
  #      end
  #    end
  #  end

  # DELETE /albums/1
  # DELETE /albums/1.xml
  #  def destroy
  #    @album = Album.find(params[:id])
  #    @album.destroy
  #
  #    respond_to do |format|
  #      format.html { redirect_to(albums_url) }
  #      format.xml  { head :ok }
  #    end
  #  end


  #--
  #
  #Created on: 11/02/2012
  #Purpose: add photo options
  #++
  def add_photo
    @album = Album.find(:all,:conditions=>["user_id=?",@login_user.id])
    @current_album_id = params[:current_album_id]
    if(params[:photo_url])
      @photo = Picture.new
      url = params[:photo_url]
      @photo.photo_detail = params[:photo_detail]
      url_host = params[:added_from]
      @photo.site_name = url_host
      @photo.share_type= params[:share_type]
      @photo.album_id = params[:album_id]
      @photo.upload_image(url)
      @group_ids = params[:group_ids]
      @group_ids.each do |grp|
        SharedTab.create(:shareable_id=>@photo.id,:group_id=>grp.to_i,:shareable_type=>"Picture")
      end if !@group_ids.blank?
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
    @photo = Picture.new(params[:photos])
    if @photo.save
      @group_ids = params[:group_ids]
      @group_ids.each do |grp|
        SharedTab.create(:shareable_id=>@photo.id,:group_id=>grp.to_i,:shareable_type=>"Picture")
      end if !@group_ids.blank?
      flash[:notice] = "Photo added successfully."
    end
    flash[:notice] = @photo.errors.first[1] if !@photo.errors.blank?
    redirect_to :back

  end

  #--
  #
  #Created on: 14/04/2012
  #Purpose:
  #++ This method is used to create the multiple photos on a album while multiple image upload.
  def create_multiple_photos
    session[:current_images] = (0...8).map{65.+(rand(25)).chr}.join unless session[:current_images]
    @photo = Picture.new(:photo => params[:picture][:path], :photo_detail => "#{session[:current_images]}", :share_type => "99", :album_id => "")
    if @photo.save
      @group_ids = params[:group_ids]
      @group_ids.each do |grp|
        SharedTab.create(:shareable_id=>@photo.id,:group_id=>grp.to_i,:shareable_type=>"Picture")
      end if !@group_ids.blank?
      flash[:notice] = "Photo added successfully."
      if @photo.save
        respond_to do |format|
          format.html {                                         #(html response is for browsers using iframe sollution)
            render :json => [@photo.to_jq_upload].to_json,
            :content_type => 'text/html',
            :layout => false
          }
          format.json {
            render :json => [@photo.to_jq_upload].to_json
          }
        end
      else
        render :json => [{:error => "custom_failure"}], :status => 304
      end
    end

   end
   
  #--
  #
  #Created on: 14/04/2012
  #Purpose:
  #++ This method is used to save the multiple photos.
   def save_multiple_photos
    params[:photo_id].each do |i|
      photo = Picture.find(i.to_i)
      description = params["photo_detail_#{i}"].blank? ? "comment" : params["photo_detail_#{i}"]
      photo.update_attributes(:photo_detail => description, :share_type => params[:photos][:share_type], :album_id => params[:photos][:album_id])
    end if !params[:photo_id].nil?
    redirect_to :back
   end

  #--
  #
  #Created on: 11/02/2012
  #Purpose: add photo options
  #++
  def find_photo
    begin
      post_agent = Mechanize.new
      @html = post_agent.get(params[:site_url]).body
      url_host =URI.parse(params[:site_url]).host
    rescue => e
    end
    render :text=>@html
  end


  #--
  #
  #Created on: 11/02/2012
  #Purpose: add photos_from_site
  #++
  def add_photos_from_site
    if(params[:photo_url])
      @url = params[:photo_url]
      @album = Album.find(:all,:conditions=>["user_id=?",@login_user.id])
      render :action=>"add_photos_from_site", :layout=>false
    end
    
  end

  #--
  #
  #Created on: 11/02/2012
  #Purpose: load all groups of login user
  #++
  def load_my_groups
    @groups = Group.find(:all,:conditions=>["user_id=?",@login_user.id])
    flash[:notice] = "Groups are not Created." if @groups.nil?
    render :partial=> "load_my_groups", :locals=>{:groups=>@groups}
  end

  #--
  #
  #Created on: 15/02/2012
  #Purpose: load full details of photo
  #++
  def load_photo_full_detail
    @picture = Picture.find(params[:id])
    render :partial=>"photo_full_detail", :locals=>{:pic=>@picture}
  end

  #--
  #
  #Created on: 15/02/2012
  #Purpose: to like the photo
  #++
  def like_picture
    @like = Like.new(:user_id=>@login_user.id,:likable_id=>params[:id],:likable_type=>"Picture")
    @pic = Picture.find(params[:id])
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
    @pic = Picture.find(params[:id])
    @like = Like.find(:last,:conditions=>["user_id=? and likable_id=? and likable_type=?",@login_user.id,params[:id],"Picture"])
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
  #Purpose: delete picture
  #++
  def delete_picture
    @pic = Picture.find(params[:id])
    if @pic.album.user_id==@login_user.id
      if @pic.destroy
        render :text=>"Success"
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
  #Purpose: post comment
  #++
  def post_photo_comment
    @pic = Picture.find(params[:picture_id].to_i)
    @comment = PhotoComment.new(:comment=>params[:comment],:user_id=>@login_user.id,:discussable_id=>params[:picture_id],:discussable_type=>"Picture")
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
    @pic = Picture.find(@comm.discussable_id)
    if @pic.album.user_id==@login_user.id or @comm.user_id==@login_user.id
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
  #Created on: 16/02/2012
  #Purpose: delete comment
  #++
  def import_picture
    if request.post?
      @album = Album.find(:all,:conditions=>["user_id=?",@login_user.id])
      @current_album_id = params[:current_album_id]
      if(params[:photo_url])
        @photo = Picture.new
        url = params[:photo_url]
        @photo.photo_detail = params[:photo_detail]
        url_host =URI.parse(url).host
        @photo.site_name = url_host
        @photo.share_type= params[:share_type]
        @photo.album_id = params[:album_id]
        @photo.upload_image(url)

        @group_ids = params[:group_ids]
        @group_ids.each do |grp|
          SharedTab.create(:shareable_id=>@photo.id,:group_id=>grp.to_i,:shareable_type=>"Picture")
        end if !@group_ids.blank?
      end
      respond_to do |format|
        format.js
      end
    else
      @pic= Picture.find(params[:id])
      @photo_url = "http://"+request.host_with_port + @pic.photo(:original)
      @album = Album.find(:all,:conditions=>["user_id=?",@login_user.id])
      render :partial=>"import_picture"
    end
  end

  #--
  #
  #Created on: 16/02/2012
  #Purpose: photo discussion page
  #++
  def photo_discussions
    @album = Album.find(:all,:conditions=>["user_id=?",@login_user.id])
    from = Time.now-30.days
    to = Time.now
    page = 1
    order_by_rating = false
    @pictures = @login_user.all_visible_pictures(from, to, page,order_by_rating,0,0)
    #@pictures = Picture.paginate(:page => 1, :per_page => 5)
  end

  #--
  #
  #Created on: 16/02/2012
  #Purpose: load discussion photos on scrolling/sorting (ajax)
  #++
  def load_photos_discussions
    @page = params[:page] ? params[:page].to_i : 1
    from = case params[:time_span]
    when "30min" then Time.now - 30.minutes
    when "day" then Time.now - 1.day
    when "week" then Time.now - 1.week
    when "year" then Time.now - 1.year
    else Time.now - 30.day
    end
    to = Time.now
    
    #order_by_rating = params[:sort_by]== "rates" ? true : false
    order = params[:sort_by]=="recent" ? nil : (params[:sort_by]=="rates")
    group_id = params[:group_id] == "" ? 0 : params[:group_id].to_i
    crowd_id = params[:crowd_id] == "" ? 0 : params[:crowd_id].to_i
    @pictures = @login_user.all_visible_pictures(from, to, @page,order,group_id, crowd_id)
  end

  #--
  #
  #Created on: 16/02/2012
  #Purpose: load album photos on scrolling page(ajax)
  #++
  def load_album_photos
    # @pictures = Picture.paginate(:page => params[:page], :per_page => 5)
    @curr_album = Album.find(params[:id])
    @pictures = @curr_album.shared_pictures(@login_user.id,params[:page].to_i)
  end
 
end
