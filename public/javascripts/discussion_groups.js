function search_groups()
{
    if(jQuery(".group_search_text").val()==jQuery(".group_search_text").next(".text_place_holder").html())
    {
        jQuery(".group_search_text").val("");
    }
    //jQuery(".group_search_text").closest("form").serialize();
    //window.location ="/discussion_groups/search_groups/"+jQuery(".group_search_text").val();
    return true;
}

function add_gmail_cont(g_id)
{
    jQuery("#public_group_user").hide();
    jQuery("#public_group_user #invite_by_email").attr("checked",true);
    jQuery.get("/discussion_groups/import_gmail_contacts/"+g_id,function(data){
        jQuery("body").append(data);
        jQuery(".pop_up").center();
    })
}

function validate_edit_email_address_form(form)
{
    flag = true;
    jQuery("#private_group_user_email",form).val(jQuery.trim(jQuery("#private_group_user_email",form).val()));
    var current_email = jQuery("#private_group_user_email",form).val();
    var emailRegExp= /^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/;
    error ="";
    if(current_email=="" || current_email=="Enter your email")
    {
        flag = false;
        error = "Please enter email";
    }
    else if(!current_email.match(emailRegExp))
    {

        flag = false;
        error = "Please enter valid email";
    }
    jQuery("#private_group_user_error",form).html(error);

    return flag;
}

