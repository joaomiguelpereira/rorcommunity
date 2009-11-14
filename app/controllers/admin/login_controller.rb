class Admin::LoginController < Admin::BaseController
 
 
  def login
  
  end
  
  def signout
    session[:user_admin] = nil
    session[:user_admin_logged_in] = nil
    redirect_to home_url
  end
  
  def signin
    logger.warn("Signing called")
     logger.info("----------------------Loggin user: ")
    if request.post?
     logger.info("----------------------Loggin user POST: ")
      #put this already in the session
      session[:email] = params[:user][:email]
      logger.info("----------------------Loggin user POST 2: ")
      #@user = User.new(params[:user])
      #
      
      logger.info("----------------------Loggin user: "+params[:user][:email])
      logger.info("----------------------Loggin user: "+params[:user][:password])
      
      #logger.info("*******************++++++++++++++++++++++++++++++"+@user.email)
      session[:user_admin] = User.authenticate(params[:user][:email], params[:user][:password]).id
      #logger.info("IS ADMIN: "+session[:user_admin].is_admin)
      #@user = nil
      session[:user_admin_logged_in] = User.find(session[:user_admin])
      logger.info("IS ADMIN: "+ session[:user_admin_logged_in].is_admin)
      unless session[:user_admin_logged_in].is_admin? && session[:user_admin_logged_in].is_admin == "1"
        logger.info("YOUR NOT ADMIN")
        raise "not admin"
      end
      redirect_to :action => session[:intended_action],
      :controller => session[:intended_controller]
    end
  rescue
    session[:user_admin_logged_in] = nil
    session[:user_admin] = nil
    logger.warn("attempt to login failed")
    flash[:notice] ="User Name/Password Invalid "
    render :action=>"login"
    
  end
end
