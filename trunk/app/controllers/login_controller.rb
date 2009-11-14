class LoginController < BaseController

  #after_filter :clear_login_in_process
  
  def login_top_form
    render :layout => false
  end
  
  def index
    unless session[:logged_user]
      render :action => 'login_form'
      return
    end
    redirect_to home_url 
  end
  
  def logout
    session[:post_filter] = nil
    session[:logged_user] = nil
    session[:user_name] = nil
    session[:include_my_own_posts] = nil
    session[:user_list_order] = nil
    cookies.delete :logged_user
    cookies.delete :p
    cookies.delete :s
    session[:user_network_post_order] = nil
    redirect_to home_url
  end
  
  def login
    
    if session[:logged_user] 
      session[:post_filter] = nil
      redirect_to home_url 
      return
    end
    @user = nil
    
    if request.get?
      session[:logged_user] = nil
      @user = User.new
      render :action => 'login_form'
    else
      
      @user = User.new(params[:user])
      if !@user.email.nil? && ( @user.email.downcase.include?("http://")|| (@user.email.downcase.include?("https://") ))
        #user_id = auth_with_open_id(@user.email, @user.password)
        redirect_to :controller=>"openidsession", :action=>"create", :openid_url=>@user.email, :session_persistent=>@user.session_persistent     
        
        return
      end
      
      logger.info("Persistent Session:"+@user.session_persistent)
      user_id = User.authenticate(@user.email, @user.password).id
      
      logger.info "Session persistent? "+@user.session_persistent
      #verifie if the user is active
      unless is_active(user_id)
        logger.info("The user is not active")
        @user = nil  
        params[:user] = nil
        redirect_to :controller=>"user", :action=>"invalid_registration", :id=>user_id
        return
      end
      if @user.session_persistent == "1"
        save_login_cookie(user_id.to_s)
      end
      
      session[:logged_user] = user_id
      
      session[:post_filter] = nil
      session[:user_network_post_order] = nil
      session[:include_my_own_posts] = nil  
      session[:user_name] = User.find(user_id).screen_name
      params[:user] = nil
      #verifies if the profile is completed
      if needs_complete_profile(user_id)
        redirect_to :controller=>"user", :action=>"first_login"
        return
      end
      
      if session[:intended_controller]
        intented_controller = session[:intended_controller]
        intended_action = session[:intented_action]
        session[:intended_controller] = nil
        session[:intented_action] = nil
        logger.info(intented_controller+intended_action)
        redirect_to :controller =>intented_controller, :action=>intended_action
      else
        redirect_to home_url
      end
    end  
    
      rescue
      flash[:notice] = BaseHelper.get_message("login.login.invalid_login")
      render :action =>"login_form"
  end
  
  def login_form
    
  end
  
  def show_login_top_form
  end
  
  def hide_login_top_form
  end
   
  private 
 
 
  def is_active(user_id)
    user = User.find(user_id)
    return user.is_active == "1"
  end
  def needs_complete_profile(user_id)
    user = User.find(user_id)
    return user.profile_compteled == 0
  end
  def save_login_cookie(userId)
    #Find the user
    tmp_user = User.find(userId)
    if (tmp_user) 
      
      cookies[:logged_user] = {:value =>userId, :expires => 720.hours.from_now }
      
      cookies[:p] = {:value =>tmp_user.password_hash, :expires => 720.hours.from_now }
      
      cookies[:s] = {:value =>tmp_user.password_salt, :expires => 720.hours.from_now }
      
      cookies[:user_name] = {:value =>tmp_user.screen_name, :expires => 720.hours.from_now }
      
    end
    
    rescue
    logger.error("Error while saving the cookie with user login")
  end
  
  
  
  def openid_missing
    logger.info("-----------------------------------------OPEN ID RESULT---------------------")
    logger.info("Result: Missing")
    
  end
  
  def openid_canceled
    logger.info("-----------------------------------------OPEN ID RESULT---------------------")
    logger.info("Result: Canceled")  
  end
  
  def openid_failed
    logger.info("-----------------------------------------OPEN ID RESULT---------------------")
    logger.info("Result: Failed")
  end
  
  def openid_success
    logger.info("-----------------------------------------OPEN ID RESULT---------------------")
    logger.info("Result: sucess")
  end
end
