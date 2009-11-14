class BaseController < ApplicationController
  layout "base_layout"
  before_filter :do_auto_login
  
  def do_auto_login
   
    logger.info "Doing Auto Login"
    unless session[:logged_user]
      if cookies[:logged_user] 
        #Call login_trough_cookie
        if User.authenticate_with_cookie(cookies[:logged_user], cookies[:p],cookies[:s])
          session[:logged_user] = cookies[:logged_user]
          session[:user_name] = cookies[:user_name]
        end
      end
    end
    #true
  end
  
  def header
    render(:layout => false)
  end
  
  
end
