class LabelController < BaseController

  def index
     render :text=>"Tag Cloud"
  end
  
  def show_posts_labelled
    label = params[:label]
    if label.nil?
      redirect_to :action=>"index"
      return
    end
    render :text=>label+"not impl"
  end
  
  
  
  def show_user_labelled
    label = params[:label]
    user_screen_name = params[:user_screen_name]
    
    if label.nil?
      redirect_to :action=>"index"
      return
    end
    
    user_id = User.get_id_from_scren_name(user_screen_name)
    
    if user_id.nil?
      redirect_to :action=>"user_not_found", :user_name=>user_screen_name
    end
    
    #verify if exists any post_filter in session
    post_filter = session[:post_filter]
    
    if post_filter.nil?
      post_filter = PostFilter.new
      session[:post_filter] = post_filter 
    end
    
    post_filter.affected_user_id = user_id
    post_filter.tags << label
    
    if session[:logged_user]
      post_filter.filter_owner = session[:logged_user] 
    else
      post_filter.filter_owner = nil
    end
    
    #redirect_to userposts_url(:user_screen_name=>user_screen_name)
    #return
    #render :text=>"USERS LABELLED WITH "+label+" "+user
  end
end
