module DiscussionGroupsHelper

  def box_border_shadow(discussion)
    str = "discussions"
    
    if discussion.discussion_type == "URL"
      str = "discussions"
    elsif discussion.discussion_type == "Picture"
      str = "disc_with_picture"
    else
      str = "commments_questions"
    end

    discussion.discussion_attachments.each do |att_file|
      if att_file.file_content_type == "application/pdf"
        str = "disc_with_pdf"
      elsif att_file.file_content_type == "application/msword"
        str = "disc_with_doc"
      end
    end if discussion.discussion_type == "Document"
    str
  end

  def box_border_shadow_popup(obj)
    type = obj.class == Discussion ? obj.discussion_type : obj.comment_type
    str = ""
    str = case type
            when 'URL' then 'user_gray_border'
            when 'Picture' then 'user_green_border'
            else 'user_yellow_border'
           end
    att_file = obj.discussion_attachments.first
    if att_file.file_content_type == "application/pdf"
      str = "user_red_border"
    elsif att_file.file_content_type == "application/msword"
      str = "user_blue_border"
    end if att_file && type == "Document"
    str
  end

end
