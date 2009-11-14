class Admin::BaseController < ApplicationController
before_filter :check_authentication, :except =>[:login,:signin]

  #Check for authetication
  def check_authentication
    unless session[:user_admin]
      session[:intended_action] = action_name
      session[:intended_controller] = controller_name
      redirect_to(:controller =>"admin/login", :action=>"login") 
    end
  end

  #def login
    #redirect to controller Login, action login
   # redirect_to :controller =>"adin/Login", :action=>"login"
  #end
end
