/* Function to check validation for Url in discussion*/
var is_sending = false;
function check_url(cur_obj)
{
    curr_object = cur_obj;
    if(!is_sending)
    {
        flag = true;
        jQuery(".error").html("");
        is_sending = true;
        $form = cur_obj.closest("form");
        var obj = $form.find("#discussion_type");
        var urlRegExp = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/;
        if(obj.val()=="URL")
        {
            url = jQuery("#discussion_discussion", $form).val();
            error_obj = jQuery(".url_error",$form);
            if(url.length==0)
            {
                error = "Please enter URL.";
                print_error(error_obj,error);
                flag = false;
            }
            else if(url.length>300)
            {
                error = "URL can not contain more than 300 characters.";
                print_error(error_obj,error);
                flag = false;
            }
            else
            {
                if(!url.match(/^(ht|f)tps?:\/\//))
                {
                    url= "http://"+url;
                    jQuery("#discussion_discussion", $form).val(url);

                }
                if(!url.match(urlRegExp))
                {
                    error = "Please enter valid URL.";
                    print_error(error_obj,error);
                    flag = false;
                }
            }

        }
        if(obj.val()=="Comment/Question")
        {
            title = jQuery("#discussion_title",$form).val();
            comment = jQuery("#discussion_discussion",$form).val();
            if(comment.length==0)
            {
                error = "Please enter Comment/Question.";
                error_obj = jQuery(".url_error",$form);
                print_error(error_obj,error);
                flag = false;
            }
            else if(comment.length>1000)
            {
                error = "Comment/Question can not contain more than 1000 characters.";
                error_obj = jQuery(".url_error",$form);
                print_error(error_obj,error);
                flag = false;
            }
            if(title.length>150)
            {
                error = "Please enter Title.";
                error_obj = jQuery(".title_error",$form);
                print_error(error_obj,error);
                flag = false;
            }

        }
        if(obj.val()=="Document")
        {
            title = jQuery("#discussion_title",$form).val();
            comment = jQuery("#discussion_discussion",$form).val();
            file_obj = jQuery("#discussions_attachment",$form);
            if(comment.length==0)
            {
                error = "Please enter Description.";
                error_obj = jQuery(".url_error",$form);
                print_error(error_obj,error);
                flag = false;
            }
            else if(comment.length>1000)
            {
                error = "Description can not contain more than 1000 characters.";
                error_obj = jQuery(".url_error",$form);
                print_error(error_obj,error);
                flag = false;
            }
            if(title.length>150)
            {
                error = "Title can not contain more than 150 characters.";
                error_obj = jQuery(".title_error",$form);
                print_error(error_obj,error);
                flag = false;
            }
            if(file_obj.val().length==0)
            {
                error="Please select document.";
                error_obj = jQuery(".file_error",$form);
                print_error(error_obj,error);
                flag = false;
            }
            else if(!file_obj.val().match(".*(\.[Pp][Dd][Ff]|\.[Dd][Oo][Cc])"))
            {
                error="Please select document of format .doc, .pdf.";
                error_obj = jQuery(".file_error",$form);
                print_error(error_obj,error);
                flag = false;
            }
        }
        if(obj.val()=="Picture")
        {
            
            file_obj = jQuery("#discussions_attachment",$form);
            title = jQuery("#discussion_title",$form).val();
            comment = jQuery("#discussion_discussion",$form).val();
            if(comment.length>1000)
            {
                error = "Description can not contain more than 1000 characters.";
                error_obj = jQuery(".url_error",$form);
                print_error(error_obj,error);
                flag = false;
            }
            if(title.length>150)
            {
                error = "Title can not contain more than 150 characters.";
                error_obj = jQuery(".title_error",$form);
                print_error(error_obj,error);
                flag = false;
            }
            var is_uploaded = jQuery("input[name='is_uploaded']",$form).val();
            if(is_uploaded=="true")
            {
                if(file_obj.val().length==0)
                {
                    error="Please select picture.";
                    error_obj = jQuery(".file_error",$form);
                    print_error(error_obj,error);
                    flag = false;
                }
                else if(!file_obj.val().match(".*(\.[Jj][Pp][Gg]|\.[Bb][Mm][Pp]|\.[Jj][Pp][Ee][Gg]|\.[Pp][Nn][Gg])"))
                {
                    error="Please select picture of format .jpg, .bmp, .jpeg, .png.";
                    error_obj = jQuery(".file_error",$form);
                    print_error(error_obj,error);
                    flag = false;
                }
            }
            else
            {
                pic = jQuery("input[name='photo_url']",$form).val();
                if(pic.length==0)
                {
                    error="Please select picture.";
                    error_obj = jQuery(".file_error",$form);
                    print_error(error_obj,error);
                    flag = false;
                }
                else if(!pic.match(".*(\.[Jj][Pp][Gg]|\.[Bb][Mm][Pp]|\.[Jj][Pp][Ee][Gg]|\.[Pp][Nn][Gg])"))
                {
                    error="Please select picture of format .jpg, .bmp, .jpeg, .png.";
                    error_obj = jQuery(".file_error",$form);
                    print_error(error_obj,error);
                    flag = false;
                }
            }
        }
        if(jQuery("#discuss_with_group").is(":checked") && jQuery(".posting_group:checked").length<=0)
        {
            jQuery("#group_id_error").html("Please select at least one group.");
            flag = false;
        }

        /*if(jQuery("#discuss_with_crowd").is(":checked") && jQuery(".posting_group:checked").length<=0)
        {
            jQuery("#crowd_id_error").html("Please select at least one crowd.");
            flag = false;
        }*/
        if(flag)
        {
            $form.ajaxSubmit();
        }
        else
        {
            is_sending = false;
        }
    }


    return false;
/*
    var url = jQuery("#discussion_discussion").val();
    var is_url = jQuery("#discussion_type").val()=="URL";
    var flag = true;
    printError("urlError","");
    jQuery(".error").html("");
    if(url!="" && !url.match(/^(ht|f)tps?:\/\//) && is_url)
    {
        url= "http://"+url;
        jQuery("#discussion_discussion").val(url);
   
    }

    if(is_url){
        if(validate_url(url)==true)
        {
            flag = false;
        }
        else
        {
            flag= true;
        }
    }
    else
    {
        if(url.length==0)
        {
            error="Please enter Comment/Question."
            printError("urlError",error);
            flag=false;
        }
        else
        {
            if(url.length>1000)
            {
                error="Comment/Question should be of maximum 1000 characters."
                printError("urlError",error);
                flag=false;
            }
        }
    }
    var $attchments = jQuery(".dis_attachment_container .discussion_attachment_file");
    var $attchments_desc = jQuery(".dis_attachment_container .discussion_attachment_desc");
    $attchments.each(function(){
        var $this = jQuery(this);
        if($this.val()=="")
        {
            $this.next(".error").html("Please select file.");
            flag = false;
        }
    });
    $attchments_desc.each(function(){
        var $this = jQuery(this);
        if($this.val().length==0)
        {
            $this.next(".error").html("Please enter description.");
            flag = false;
        }
        else
        {
            if($this.val().length>100)
            {
                $this.next(".error").html("Description should be of maximum 100 characters.");
                flag = false;
            }
        }

    });

    if(jQuery("#discuss_with_group").is(":checked") && jQuery(".posting_group:checked").length<=0)
    {
        jQuery("#group_id_error").html("Please select at least one group.");
        flag = false;
    }

    if(jQuery("#discuss_with_crowd").is(":checked") && jQuery(".posting_group:checked").length<=0)
    {
        jQuery("#crowd_id_error").html("Please select at least one crowd.");
        flag = false;
    }

    if(is_sending){
        flag = false;
    }
    
    if(flag){
        is_sending = true;
    }
    return flag;*/
}

function validate_url(url){
    error_blank_url();
    var flag=false;
    var urlRegExp = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/;
    if(url.length==0)
    {
        error="Please enter url."
        printError("urlError",error);
        flag=true;
    }
    else
    {
        if(url.length>300)
        {
            error="Url is too long."
            printError("urlError",error);
            flag=true;
        }
    }
    if(url.length!=0)
    {
        if(!url.match(urlRegExp))
        {
            error="Please enter valid url."
            printError("urlError",error);
            flag=true;
        }
    }

    if(flag==true)
    {
        return flag;
    }
}

function error_blank_url()
{
    document.getElementById("urlError").innerHTML="";
}

function set_comment_type(obj)
{
    var $form = obj.closest("form");
    if($form.attr( 'action' ) == '/discussions/post_comments' )
     {
      jQuery('#fileupload').attr('action', '/discussions/post_multiple_comments');
     }
    else if($form.attr( 'action' ) == '/discussions/post_comment_responses' )
     {
      jQuery('#fileupload').attr('action', '/discussions/post_multiple_comment_responses');
     }
     jQuery("#parent_id").val(jQuery("#p_id",$form).val());
     jQuery("#discussion_id").val(jQuery("#dis_id",$form).val());

    jQuery(".error").html("")
    jQuery(".com_file",$form).hide();
    if(obj.val()=="URL")
    {
        jQuery(".picture_options_span",$form).hide();
        jQuery(".com_title,.comment_title_field, .discussion_title_field,.com_file_cont",$form).hide().val("");
        jQuery(".com_Description",$form).html("URL:");
    }
    if(obj.val()=="Comment/Question")
    {
        jQuery(".picture_options_span",$form).hide();
        jQuery(".com_title,.comment_title_field,.discussion_title_field",$form).show();
        jQuery(".com_file_cont",$form).hide().val("");
        jQuery(".com_Description",$form).html("Comment/Question:");
    }
    if(obj.val()=="Document")
    {
        jQuery(".picture_options_span",$form).hide();
        jQuery(".com_title,.comment_title_field, .discussion_title_field,#disc_type_file,.com_file_cont,.com_file",$form).show();
        jQuery(".com_file",$form).show();
        jQuery(".com_Description",$form).html("Description:");
    }
    if(obj.val()=="Picture")
    {
        jQuery(".com_title,.comment_title_field, .discussion_title_field, #disc_type_file, .picture_options_span",$form).show();
        jQuery(".com_file",$form).hide();
        jQuery(".com_Description",$form).html("Description:");
    }
}
var cur_popup=null;
function show_find_photo_for_comment(obj)
{
    obj.closest('#disc_type_file').find('.upld_pic_span').hide();
    pic_form=obj.closest('form');
    cur_popup = jQuery(".grey_overlay:visible");
    cur_popup.hide();
    jQuery('#add_photo_popup').show();
}
