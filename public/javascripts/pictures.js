function check_phot_comment_form(curr_obj)
{
    var comm = curr_obj.closest(".ph_post_com_div").find(".ph_com_text_area");
    var flag= true;
    var error = "";
    if(comm.val().length==0)
    {
        error = "Please enter comment."
        flag = false;
    }
    else
    {
        if(comm.val().length>1000)
        {
            error = "Comment can't be of more than 1000 characters."
            flag = false;
        }
    }
    if(error.length!=0)
        display_flash_message(error);
    return flag;
    
}

function delete_picture(p_id)
{
    var answer = confirm("Are you sure you want to delete?");
    if(answer)
    {
        jQuery.get("/delete_picture/"+p_id,function(data){
            if(data=="Success")
            {
                $item = jQuery(".picture_"+p_id);
                jQuery(".photos_container").masonry( 'remove',$item ).masonry( 'reload');
             if(jQuery('.photos_container .photos').length == 0){
                jQuery('#no_photos_in_album').html('There are no photos available for you.');
                }

            }
        });
    }
}


//Delete comment on pictures
function delete_photo_comment(p_c_id)
{
    var answer = confirm("Are you sure you want to delete?");
    if(answer)
    {
        jQuery.get("/delete_picture_comment/"+p_c_id,function(data){
            if(data=="Success")
            {
                jQuery(".photo_comment_"+p_c_id).fadeOut().remove();
                jQuery(".photos_container").masonry( 'reload');
            }
        });
    }
}
function import_picture(p_id)
{
    jQuery.get("/import_picture/"+p_id,function(data){
        var $html= jQuery(data);
        jQuery("body").append($html);
    });

}


function display_image_full_detail(ap_id)
{
    toggle_ajax_loader();
    jQuery.get("/load_photo_full_detail/"+ap_id,function(data){
        toggle_ajax_loader();
        jQuery("body").append(data);
    });
}

function display_image_full_popup(pic_id)
{
    toggle_ajax_loader();
    jQuery.get("/discussion_groups/load_photo_full_detail/"+pic_id,function(data){
        toggle_ajax_loader();
        jQuery("body").append(data);
    });
}

function delete_image(p_id)
{
    var answer = confirm("Are you sure you want to delete?");
    if(answer)
    {
        jQuery.get("/discussion_groups/delete_picture/"+p_id,function(data){
            if(data=="Success")
            {
                $item = jQuery(".picture_"+p_id);
                jQuery(".photos_container").masonry( 'remove',$item ).masonry( 'reload');
                
            }
        });
    }
}

function import_picture_from_group_album(p_id)
{
    jQuery.get("/discussion_groups/import_picture/"+p_id,function(data){
        var $html= jQuery(data);
        jQuery("body").append($html);
    });
}