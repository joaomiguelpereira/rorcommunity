ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.

  #This set up the default route to the controller community, action index
  map.home '', :controller => 'post', :action=> 'front_page'
  map.admin 'admin', :controller => 'admin/admin', :action=> 'index'
  map.register 'register', :controller=> 'user', :action =>'register'
  map.login 'login', :controller=> 'login', :action =>'index'
  map.submit 'submit', :controller=> 'post', :action =>'submit'
  map.user 'users/:user_screen_name', :controller=>'user', :action=>"view_public_profile", :requirements=>{:user_screen_name=>/(?:[a-z\d](?:[a-z\d_]*[a-z\d])?)(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(?:\.[a-z\d](?:[a-z\d-]*[a-z\d])?)*/i}
  map.userposts 'users/:user_screen_name/posts', :controller=>'user', :action=>"user_posts", :requirements=>{:user_screen_name=>/(?:[a-z\d](?:[a-z\d_]*[a-z\d])?)(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(?:\.[a-z\d](?:[a-z\d-]*[a-z\d])?)*/i}
  map.users 'users', :controller=>'user', :action=>"list_users"
  map.post ":permalink", :controller=>'post', :action=>'view_post', :requirements=>{:permalink=>/(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(\.html)/}
  map.tag "tag/:label", :controller=>'post', :action=>'front_page'
  map.usernetwork 'users/:user_screen_name/network', :controller=>'user', :action=>"user_friends", :requirements=>{:user_screen_name=>/(?:[a-z\d](?:[a-z\d_]*[a-z\d])?)(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(?:\.[a-z\d](?:[a-z\d-]*[a-z\d])?)*/i}
  
  map.usernetworktag 'users/:user_screen_name/network/tag/:label', :controller=>'user', :action=>'user_friends',:requirements=>{:user_screen_name=>/(?:[a-z\d](?:[a-z\d_]*[a-z\d])?)(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(?:\.[a-z\d](?:[a-z\d-]*[a-z\d])?)*/i}
  
  map.tagcloud "tagcloud", :controller=>'tag_cloud', :action=>'tag_cloud'
  
  #map.usertag "users/:user_screen_name/tag/:label", :controller=>'label', :action=>'show_user_labelled',:requirements=>{:user_screen_name=>/(?:[a-z\d](?:[a-z\d_]*[a-z\d])?)(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(?:\.[a-z\d](?:[a-z\d-]*[a-z\d])?)*/i}
  
  map.usertag "users/:user_screen_name/tag/:label", :controller=>'user', :action=>'user_posts',:requirements=>{:user_screen_name=>/(?:[a-z\d](?:[a-z\d_]*[a-z\d])?)(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(?:\.[a-z\d](?:[a-z\d-]*[a-z\d])?)*/i}
  
  map.anonymous_rss "anonymous-rss/:channel_name", :controller=>'post', :action=>'rss_use_channel'
  
  map.uservoted "users/:user_screen_name/voted", :controller=>'user', :action=>'show_voted_links',:requirements=>{:user_screen_name=>/(?:[a-z\d](?:[a-z\d_]*[a-z\d])?)(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(?:\.[a-z\d](?:[a-z\d-]*[a-z\d])?)*/i}

  map.search "search", :controller=>'post', :action=>'search'
  
  map.usercategory 'users/:user_screen_name/category/:category', :controller=>'user', :action=>'user_posts',:requirements=>{:user_screen_name=>/(?:[a-z\d](?:[a-z\d_]*[a-z\d])?)(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(?:\.[a-z\d](?:[a-z\d-]*[a-z\d])?)*/i}
  map.not_found "not_found.html", :controller=>"community", :action=>"not_found"
  
  map.savedby "whosaved/:permalink", :controller=>'post', :action=>'who_saved',:requirements=>{:permalink=>/(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(\.html)/}
  map.votedby "whovoted/:permalink", :controller=>'post', :action=>'who_voted',:requirements=>{:permalink=>/(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(\.html)/}
  
  map.frontpage_rss "rss", :controller=>"post", :action=>"feed_rss"
  
  map.personalized_rss "rss/:permalink", :controller=>"feed", :action=>"show_feed" 
  map.personalized_rss ":user_screen_name/rss/:permalink", :controller=>"feed", :action=>"show_feed", :requirements=>{:user_screen_name=>/(?:[a-z\d](?:[a-z\d_]*[a-z\d])?)(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(?:\.[a-z\d](?:[a-z\d-]*[a-z\d])?)*/i}
  map.channel ":user_screen_name/channel/:permalink", :controller=>"feed", :action=>"show_channel", :requirements=>{:user_screen_name=>/(?:[a-z\d](?:[a-z\d_]*[a-z\d])?)(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(?:\.[a-z\d](?:[a-z\d-]*[a-z\d])?)*/i}
  
  map.user_channels ":user_screen_name/channels", :controller=>"feed", :action=>"list_channels",:requirements=>{:user_screen_name=>/(?:[a-z\d](?:[a-z\d_]*[a-z\d])?)(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(?:\.[a-z\d](?:[a-z\d-]*[a-z\d])?)*/i}
  map.channels "/channels", :controller=>"feed", :action=>"list_channels"
  map.category "category/:category", :controller=>'category', :action=>'show_posts_from_category'
 
  map.open_id_complete 'session', :controller => "openidsession", :action => "create", :requirements => { :method => :get }
  #map.resource :openidsession
  
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  map.connect "*anything", :controller => 'community', :action =>'unknow_request'
  map.connect ":controller/*anything", :controller => 'community', :action =>'unknow_request'
end
