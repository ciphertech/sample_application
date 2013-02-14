FavTabs::Application.routes.draw do
  #resources :discussion_groups

  #Ref:- http://8raystech.com/2011/02/08/redirecting-www-url-requests-to-non-www-url-in-rails-3
  constraints(:host => "www.convorum.com") do
    match "(*x)" => redirect { |params, request|
      URI.parse(request.url).tap { |x| x.host = "convorum.com" }.to_s
    }
  end 
  match "discussions/create_multiple_discussion"  => "discussions#create_multiple_discussion"
  match "discussion_groups/create_multiple_discussion"  => "discussion_groups#create_multiple_discussion"
  match "discussions/post_multiple_comments"  => "discussions#post_multiple_comments"
  match "discussions/save_multiple_comments"  => "discussions#save_multiple_comments"
  resources :albums

  resources :profile_pictures

  resources :ratings

  resources :comments

  resources :user_discussions

  resources :follower_followings
  match "discussions/updates_from_following_follower" => "discussions#updates_from_following_follower"
  resources :messages
  match 'new_message' => 'messages#new_message'
  match 'sent_messages' => 'messages#sent_messages'
  match 'message_delete' => 'messages#message_delete'
  match 'from_follower_following' => 'messages#from_follower_following'
  resources :tab_sites

  resources :tabs

  resources :user_details
  match 'logins/create' => 'logins#create'
  match 'logins/activate/:id' => 'logins#activate'
  match 'logins/forgot_password' => 'logins#forgot_password'
  match 'login' => 'logins#login'
  match 'logout' => 'logins#logout'
  match 'test_remote_call' => 'users#test_remote_call'

  match 'users/edit_profile_picture' => 'users#edit_profile_picture'
  match 'load_more_search_result' => 'users#load_more_search_result'

  match 'about_us' => 'logins#about_us'
  match 'contact_us' => 'logins#contact_us'


  # resources :logins do
  #  collection do
  #   get 'home'
  # end
  # end
  match "users/profile/:id"  => "users#my_account"

  match 'users/followers/:id' => 'users#followers'
  match 'users/followings/:id' => 'users#followings'
  match 'users/follow/:id' => 'users#follow'
  match 'users/set_email_updates/:id' => 'users#set_email_updates'
  match 'follower_following_delete/:id' => 'users#follower_following_delete'

  match "users/add_tab"  => "users#add_tab"
  match "users/add_current_tab"  => "users#add_current_tab"
  match "users/edit_tab"  => "users#edit_tab"
  match "users/delete_tab"  => "users#delete_tab"
  match "users/delete_site_url"  => "users#delete_site_url"
  match "users/edit_site_url"  => "users#edit_site_url"
  match "users/create_site"  => "users#create_site"
  match "users/find_people" => "users#find_people"
  match "users/manage_groups" => "users#manage_groups"
  match "users/create_group" => "users#create_group"
  match "users/edit_group" => "users#edit_group"
  match "users/add_email" => "users#add_email"
  match "users/add_email_to_crowd/:id" => "users#add_email_to_crowd"
  match "users/import_gmail_contacts/:id" => "users#import_gmail_contacts"

  match "users/delete_group" => "users#delete_group"

  match "albums/create_album" => "albums#create_album"
  match "albums/edit_album" => "albums#edit_album"
  match "albums/delete_album/:id" => "albums#delete_album"
  match "share_album_in_group/:id" => "albums#share_album_in_group"
  match "share_photo_in_group/:id" => "albums#share_photo_in_group"
  match "albums/create_multiple_photos" => "albums#create_multiple_photos"
  match "albums/save_multiple_photos" => "albums#save_multiple_photos"

  match "find_photo" => "albums#find_photo"
  match "add_photo" => "albums#add_photo"
  match "add_photos_from_site" => "albums#add_photos_from_site"
  match "load_my_groups" => "albums#load_my_groups"
  match "add_photo_from_system" => "albums#add_photo_from_system"
  match "load_photos_discussions" => "albums#load_photos_discussions"
  match "load_album_photos/:id" => "albums#load_album_photos"
  
  match "users/set_tab_private/:id"  => "users#set_tab_private"
  match "users/set_tab_public/:id"  => "users#set_tab_public"
  match "share_with_group/:id"  => "users#share_with_group"
  match "add_to_group/:id"  => "users#add_to_group"
  match "non_site_add_to_crowd/:id"  => "users#non_site_add_to_crowd"

  match "remove_from_group/:id"  => "users#remove_from_group"
  match "remove_non_site_from_crowd/:id"  => "users#remove_non_site_from_crowd"
  
  resources :discussions
  match "discussions/create_discussion"  => "discussions#create_discussion"

  match "discussions/add_title_discription"  => "discussions#add_title_discription"
  match "discussions/add_title_discription/:id"  => "discussions#add_title_discription"
  match "discussions/save_multiple_discussion"  => "discussions#save_multiple_discussion"
  match "discussions/return_to_previous/:id"  => "discussions#return_to_previous"
  match "discussions/updates_from_following_follower" => "discussions#updates_from_following_follower"
  match "discussions/post_comments"  => "discussions#post_comments"
  match "discussions/join_discussion/:id"  => "discussions#join_discussion"
  match "load_comments/:id"  => "discussions#load_comments"
  match "load_my_comments/:id"  => "discussions#load_my_comments"
  match "load_my_discussions/:id"  => "discussions#load_my_discussions"
  match "load_my_discussions_on_scroll"  => "discussions#load_my_discussions_on_scroll"
  match "load_most_pop_discussions_on_scroll"  => "discussions#load_most_pop_discussions_on_scroll"


  match "discussions/web_content/:id"  => "discussions#web_content"


  match "discussions/post_multiple_comment_responses"  => "discussions#post_multiple_comment_responses"
  match "discussions/post_comment_responses"  => "discussions#post_comment_responses"
  match "all_discussion" => "discussions#all_discussion"
  match "all_discussion" => "discussions#all_discussion"
  match "load_discussion_as_per_time/:id" => "discussions#load_discussion_as_per_time"
  match "discussions/update_comment_responses" => "discussions#update_comment_responses"
  match "delete_comment/:id" => "discussions#delete_comment"
  match "delete_discussion/:id" => "discussions#delete_discussion"
  match "search_user_names_for_message/:term" => "users#search_user_names_for_message"
  match "show_discussion/:id" => "discussions#show_discussion"
  match "load_my_comments_on_scroll" => "discussions#load_my_comments_on_scroll"
  match "load_more_feeds" => "discussions#load_more_feeds"



  match "albums/index/:id"  => "albums#index"
  match "find_photo" => "albums#find_photo"
  match "add_photo" => "albums#add_photo"
  match "add_photos_from_site" => "albums#add_photos_from_site"
  match "load_my_groups" => "albums#load_my_groups"
  match "load_photo_full_detail/:id" => "albums#load_photo_full_detail"
  match "like_picture/:id" => "albums#like_picture"
  match "unlike_picture/:id" => "albums#unlike_picture"
  match "delete_picture/:id" => "albums#delete_picture"
  match "post_photo_comment" => "albums#post_photo_comment"
  match "delete_picture_comment/:id" => "albums#delete_picture_comment"
  match "import_picture/:id" => "albums#import_picture"
  match "photo_discussions" => "albums#photo_discussions"
  match "upload_photos" => "albums#create_multiple_albums"

  match "discussion_groups/import_picture/:id" => "discussion_groups#import_picture"
  match "discussion_groups/delete_picture/:id" => "discussion_groups#delete_picture"
  match "discussion_groups/delete_picture_comment/:id" => "discussion_groups#delete_picture_comment"
  match "discussion_groups/post_photo_comment" => "discussion_groups#post_photo_comment"
  match "discussion_groups/load_photo_full_detail/:id" => "discussion_groups#load_photo_full_detail"
  match "discussion_groups/load_pictures/:id" => "discussion_groups#load_pictures"
  match "discussion_groups/like_picture/:id" => "discussion_groups#like_picture"
  match "discussion_groups/unlike_picture/:id" => "discussion_groups#unlike_picture"
  match "discussion_groups/add_photo_from_system" => "discussion_groups#add_photo_from_system"
  match "discussion_groups/add_photo" => "discussion_groups#add_photo"
  match "discussion_groups/group_album/:id" => "discussion_groups#group_album"
  match "discussion_groups/create_discussion" => "discussion_groups#create_discussion"
  match "discussion_groups/create_discussion_group" => "discussion_groups#create_discussion_group"
  match "edit_discussion_group/:id" => "discussion_groups#edit_discussion_group"
  match "discussion_groups/delete_discussion_group/:id" => "discussion_groups#delete_discussion_group"
  match "discussion_groups/search_groups/" => "discussion_groups#search_groups"
  match "discussion_groups/add_user_to_groups/:id" => "discussion_groups#add_user_to_groups"
  match "discussion_groups/invite_user_to_groups/:id" => "discussion_groups#invite_user_to_groups"
  match "load_more_groups/:search_text" => "discussion_groups#load_more_groups"
  match "search_for_group/:term" => "users#search_for_group"
  match "notifications/:id" => "discussion_groups#notifications"
  match "accept_invitation/:id" => "discussion_groups#accept_invitation"
  match "decline_invitation/:id" => "discussion_groups#decline_invitation"
  match "join_group/:id" => "discussion_groups#join_group"
  match "unjoin_group/:id" => "discussion_groups#unjoin_group"
  match "leave_joined_group/:id" => "discussion_groups#leave_joined_group"
  match "discussions/load_feeds_by_group/:id" => "discussions#load_feeds_by_group"
  match "load_group_discussion/:id" => "discussions#load_group_discussion"
  match "load_group_discussions_on_scroll/:id" => "discussion_groups#load_group_discussions_on_scroll"

  match "discussion_groups/delete_added_group_user/:id" => "discussion_groups#delete_added_group_user"
  match "discussion_groups/edit_added_group_user/:id" => "discussion_groups#edit_added_group_user"

  match 'discussion_groups/invite_emails_to_group/:id' => 'discussion_groups#invite_emails_to_group'
  match 'discussion_groups/import_gmail_contacts/:id' => 'discussion_groups#import_gmail_contacts'

  resources :discussion_groups do
    collection do
      get 'search_groups'
    end
  end

  match "logins/invitation_sign_up/:id" => "logins#invitation_sign_up"
  #following path added for the autocomplete
  resources :users do
    get :autocomplete_user_username, :on => :collection
    member do
      post :rate
    end
  end
  root :to => "logins#home"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
