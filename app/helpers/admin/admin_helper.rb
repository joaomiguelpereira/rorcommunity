module Admin::AdminHelper
 #Check for authetication
 #
  def check_authentication
    unless session[:user]
      session[:intended_action] = action_name
      session[:intended_controller] = controller_name
      redirect_to(:controller =>"admin/login", :action=>"login") 
    end
  end
 
end
