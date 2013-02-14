// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :def
var is_sending = false;
flag = true;
function button_disable(){
    if(is_sending){
        flag = false;
    }

    if(flag){
        is_sending = true;
    }
    return flag;
}




function printError(targetAreaId,errorMsg){
    document.getElementById(targetAreaId).innerHTML= "<span class='error'>"+errorMsg+"</span>" ;
}

function set_effects()
{

    jQuery('.comment_link,.response_link, .cancel_link,.toggle_comment,.cancel_edit_link').unbind('click');
    /* UI Functionality */
    jQuery(".comment_link").click(function(){
        var current_link = jQuery(this);
        jQuery("#comment_discussion_id").val(jQuery(this).attr("id"));
        if(current_link.html()=="Post Comment")
        {
            current_link.parent().parent().children(".comment_form_div").slideDown();
            current_link.parent().hide();
        //current_link.next().slideDown();
        }
        else
        {
            current_link.parent().parent().children(".comment_form_div").slideUp();
            current_link.show();
        }
        return false;
    });


    /* For  response comment*/
    jQuery(".response_link").click(function(){
        var current_link = jQuery(this);
        if(current_link.html()=="Post Comment")
        {
            current_link.parent().parent().children(".comment_form_div").slideDown();
            current_link.parent().hide();
        //current_link.next().slideDown();
        }
        else
        {
            current_link.parent().parent().children(".comment_form_div").slideUp();
            current_link.show();
        }
        return false;
    });
    jQuery(".cancel_link").click(function(){
        var current_link = jQuery(this);
        current_link.parent().slideUp(function(){
            current_link.parent().prev().show();
        });
        return false;
    });
    jQuery(".toggle_comment").click(function(){
        var current_ex_btn = jQuery(this);

        current_ex_btn.parent().parent().children(".comments_div").css('padding-left','10px').toggle();

        if(current_ex_btn.hasClass("expand_btn"))
        {
            current_ex_btn.removeClass("expand_btn").addClass("collapse_btn");
        }
        else if(current_ex_btn.hasClass("collapse_btn"))
        {
            current_ex_btn.removeClass("collapse_btn").addClass("expand_btn");
        }
        return false;
    });
    jQuery(".edit_comment_link").click(function(){
        var current_link = jQuery(this);
        var current_comment_text = current_link.closest(".comment_detail_div").find(".comment_text");
        current_link.closest(".comment_detail_div").find(".edit_comment_div").show();
        //current_link.closest(".comment_detail_div").find(".edit_comment_div").find("form").children(".post_comment_text_area").html(current_comment_text.html());
        current_comment_text.hide();
        current_link.parent().hide();
        return false;
    });

    jQuery(".cancel_edit_link").click(function(){
        var current_link = jQuery(this);
        current_link.parent().slideUp(function(){
            current_link.closest(".comment_detail_div").find(".comment_text").show();
            current_link.closest(".comment_detail_div").find(".comment_details").show();
            current_link.closest(".comment_detail_div").find(".post_comment_div span:first").show();


        });
        return false;
    });


}



var curr_object = null;
var is_sending = false;
function post_comment(cur_obj)
{

    curr_object = cur_obj;
    if(!is_sending)
    {
        flag = true;
        jQuery(".error").html("");
        is_sending = true;
        $form = cur_obj.closest("form");
        var obj = $form.find(".comment_type");
        var urlRegExp = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/;
        if(obj.val()=="URL")
        {
            url = jQuery("#comment_comment", $form).val();
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
                    jQuery("#comment_comment", $form).val(url);

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
            title = jQuery("#comment_title",$form).val();
            comment = jQuery("#comment_comment",$form).val();
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
            title = jQuery("#comment_title",$form).val();
            comment = jQuery("#comment_comment",$form).val();
            file_obj = jQuery(".com_file",$form);
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
            file_obj = jQuery(".com_file",$form);
            title = jQuery("#comment_title",$form).val();
            comment = jQuery("#comment_comment",$form).val();
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
//jQuery("#"+form_id).submit();
/*jQuery.get('/load_comments/'+d_id, function(data) {
     jQuery("#"+form_id).parent().parent().parent().parent().children(".comments_div").html(data);
     jQuery("#"+form_id).parent().hide();
     jQuery("#"+form_id).parent().prev().children(".comment_link").show("");
    });*/
}


var curr_object = "";

function update_comment_response(curr_obj)
{
    curr_object = curr_obj;
    $form = curr_obj.closest("form");
    $form.ajaxSubmit();

}

function delete_comment(curr_obj, cid)
{
    var answer = confirm("Are you sure, you want to delete comment?")
    if(answer)
    {
        curr_object = curr_obj;
        jQuery.get('/delete_comment/'+cid, function(data){
            if(data=="Success")
            {
                var current = curr_object.closest(".comment_"+cid).parent().parent();
                curr_object.closest(".comment_"+cid).remove();
                if(current.children(".comments_div").children("div").length==0)
                {
                    current.children("div:first-child").find(".toggle_comment").removeClass("collapse_btn").removeClass("expand_btn");
                    if(!current.children(".comments_div").hasClass("main_comment_div"))
                    {
                       current.children(".comments_div").hide();
                    }
                }
                
                display_flash_message("Comment deleted successfully.");
                
            }
            else
            {
                alert("Comment can't be deleted.")
            }
        });
    }
    return false;
}

function post_comment_response(curr_obj)
{
    curr_object = curr_obj;
    if(!is_sending)
    {
        is_sending = true;
        curr_obj.parent().parent().children("form").submit();
    }

}


//For deleting discussion
function delete_discussion(d_id,cur_obj)
{
    var answer = confirm("Are you sure, you want to delete discussion?");
    if(answer)
    {
        jQuery.get('/delete_discussion/'+d_id,function(data){
            if(data=="Success")
            {
                cur_obj.closest('.masonry_block').remove();
                jQuery("#result").masonry( "reload" );
                display_flash_message("Discussion deleted successfully.");
            }
            else
            {
                alert("Discussion could not deleted please try again.")
            }
        });
    }
    return false;
}

//For deleting discussion
function delete_discussion_from_profile(d_id,cur_obj)
{
    var answer = confirm("Are you sure, you want to delete discussion?");
    if(answer)
    {
        jQuery.get('/delete_discussion/'+d_id,function(data){
            if(data=="Success")
            {
                jQuery(".discussion_"+d_id).remove();
                display_flash_message("Discussion deleted successfully.");
            }
            else
            {
                alert("Discussion could not deleted please try again.")
            }
        });
    }
    return false;
}

function apply_scroll_effects()
{
    jQuery(".url_block,.search_results_scrolled_div").hover(function(){
        jQuery(this).css("overflow","auto");
        jQuery(this).scrollTop(jQuery(this).data("top_pos"));

    },function(){
        jQuery(this).css("overflow","hidden");
        jQuery(this).data("top_pos",jQuery(this).scrollTop());
    });

}

function apply_scroll_effect_to(div_class)
{
    jQuery("."+div_class).hover(function(){
        jQuery(this).css("overflow","auto");
        jQuery(this).scrollTop(jQuery(this).data("top_pos"));

    },function(){
        jQuery(this).css("overflow","hidden");
        jQuery(this).data("top_pos",jQuery(this).scrollTop());
    });

}




//
//For displaying flash message
function display_flash_message(msg)
{
    jQuery("#flash_message_popup").find(".pop_up_message").html(msg);
    jQuery("#flash_message_popup .pop_up").css({
        "position":"fixed",
        "top":(jQuery(window).height()-jQuery("#flash_message_popup .pop_up").height())/2+"px"
    });
    jQuery("#flash_message_popup .pop_up").css({
        "position":"fixed",
        "left":(jQuery(window).width()-jQuery("#flash_message_popup .pop_up").width())/2+"px"
    });
    jQuery("#flash_message_popup").fadeIn();
    var t=setTimeout("jQuery('#flash_message_popup').fadeOut();",3000)
}


function expand_user_comment_tree(curr_obj)
{
    if(curr_obj.hasClass("root_div"))
    {
        if(curr_obj.children(":first").children("a").hasClass("toggle_comment"))
        {
            curr_obj.children(":first").children("a.toggle_comment").removeClass("expand_btn").addClass("collapse_btn");
        }
        return;
    }
    else
    {
        if(!is_first_node)
        {
            curr_obj.show();
            if(curr_obj.hasClass("comments_div"))
            {
                curr_obj.css('padding-left','10px');
            }
            if(curr_obj.children(":first").children("a").hasClass("toggle_comment"))
            {
                curr_obj.children(":first").children("a").removeClass("expand_btn").addClass("collapse_btn");
            }
        }
        is_first_node= false;
        expand_user_comment_tree(curr_obj.parent());
    }

}



function add_to_group(user_id)
{
    jQuery.get("/add_to_group/"+user_id,function(data){
        //alert(data);
        jQuery("body").append(data);
        jQuery("#add_to_group_popup").fadeIn();
        jQuery("#add_to_group_popup #user_id").val(user_id);
    });
}

function non_site_add_to_group(user_id)
{
    jQuery.get("/non_site_add_to_crowd/"+user_id,function(data){
        jQuery("body").append(data);
        jQuery("#non_site_add_to_crowd_popup").fadeIn();
        jQuery("#non_site_add_to_crowd_popup #user_id").val(user_id);
    });
}

function check_add_to_group_form()
{
    if(jQuery("#add_to_group_rows").find("input[type='checkbox']:checked:not(:disabled)").length==0)
    {
        jQuery("#add_to_form_error").html("Please select at least one group.");
        return false;
    }
}

function show_discussion(d_id)
{
    jQuery("#ajax_loader").show();
    jQuery(".pop_up").center();
    jQuery.get("/show_discussion/"+d_id,function(data){
        jQuery("body").append(data);
        jQuery("#ajax_loader").hide();

    });
}

function toggle_ajax_loader()
{
    if(!jQuery("#ajax_loader").is(":visible"))
    {
        jQuery("#ajax_loader").show();
        jQuery("#ajax_loader .pop_up").center();
    }
    else
    {
        jQuery("#ajax_loader").hide();
    }
}

function print_error(obj, error)
{
    obj.html(error);
}

function apply_ratings()
{
    jQuery('.rating_class').each(function(v,i){
        if(!jQuery(this).children("img").size()>0)
        {
            jQuery(this).raty({
                click: function(score, evt) {
                    current_object = jQuery(this);
                    $(this).parent().submit();
                }
            });
        }

    });


    jQuery(".rating_container").each(function(v,i){
        var value = jQuery(this).children("span").html();
        if(!jQuery(this).children('.rating_class_fixed').children("img").size()>0)
        {
            jQuery(this).children('.rating_class_fixed').raty({
                readOnly:	true,
                start:		value
            });
        }

    });
}

function set_comment_form()
{
    var com_types = jQuery(".comment_type");

    com_types.each(function(v,i){
        obj = $(this);
        set_comment_type(obj)
        
    });
}

function set_discussion_form(this_obj)
{
    cur_form = this_obj.closest("form");
    if(cur_form.attr( 'action' ) == '/discussions/create_discussion' )
    {
    jQuery('#fileupload').attr('action', '/discussions/create_multiple_discussion');
    }
    else if(cur_form.attr( 'action' ) == '/discussion_groups/create_discussion' )
    {
    jQuery('#fileupload').attr('action', '/discussion_groups/create_multiple_discussion');
    }

    jQuery(".picture_options_span,.upld_pic_span", cur_form).hide();

    if(jQuery('#discussion_title').val().length != 0)
    {
        jQuery('#discussion_title').data('value', jQuery('#discussion_title').val());
    }
    jQuery('#discussion_title').val('');

    if(jQuery('#discussion_type').val() == "URL") {
        jQuery('#disc_type').hide();
        jQuery('#disc_type_file').hide();
        jQuery('#disc_type_text').html('URL:');

    }
    if(jQuery('#discussion_type').val() == "Comment/Question") {
        jQuery('#discussion_title').val(jQuery('#discussion_title').data('value'));
        jQuery('#disc_type_text').html('Comment/Question:');
        jQuery('#disc_type').show();
        jQuery('#disc_type_file').show();

    }
    if(jQuery('#discussion_type').val() == "Document") {
        jQuery(".upld_pic_span", cur_form).show();
        jQuery('#disc_type').hide();
        jQuery('#disc_type_file').show();
        jQuery('#disc_type_text').html('Description:');
        jQuery(".upld_pic_span", cur_form).show();
    }
    if(jQuery('#discussion_type').val() == "Picture") {
        jQuery(".picture_options_span", cur_form).show();
        jQuery(".upld_pic_span", cur_form.closest("form")).hide();
        jQuery('#discussion_title').val(jQuery('#discussion_title').data('value'));
        jQuery('#disc_type').show();
        jQuery('#disc_type_file').show();
        jQuery('#disc_type_text').html('Description:');

    }
}


//
//For validatiing gmail credential form for importing contacts
function check_gmail_auth_form(form)
{
    jQuery(".error", form).html("");
    var email = jQuery(".g_email",form).val();
    var pass = jQuery(".g_pass",form).val();
    var emailRegExp=/^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/;
    var at_reg = /@/;
    flag = true;
    if(jQuery.trim(email).length == 0)
    {
        error = 'Please enter username.';
        flag = false;
        jQuery(".g_email_error", form).html(error);
    }
    else if(email.match(at_reg) && !email.match(emailRegExp))
    {
        error = 'Please enter valid email address.';
        flag = false;
        jQuery(".g_email_error", form).html(error);
    }

    if(jQuery.trim(pass).length == 0)
    {
        error = 'Please enter password.';
        flag = false;
        jQuery(".g_pass_error", form).html(error);
    }
    if(flag)
    {
      toggle_ajax_loader();
    }
    return flag;
}

//
//For validatiing contacts selected or not
function validate_add_gmail_cont_form(form)
{
    //contacts = jQuery(".conatcts_chk",form);
    var flag = true;
    if(jQuery(".conatcts_chk:checked",form).length == 0)
    {
        flag = false;
        error = "Please select at least one email to invite in group."
        display_flash_message(error);
    }
    return flag;
}