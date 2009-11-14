class Admin::UserController < Admin::BaseController
  
  
  #Remove a user from DB
  def remove_user
    message = "";
    #If the user id logged in we'll not remove it
    if params[:id].to_s == session[:user_admin].to_s
      message = "You are logged in and you can't remove yourseld"
    else
      user_to_delete = User.find(params[:id])
      message = "User #{user_to_delete.screen_name} removed"
      user_to_delete.destroy
    end
    redirect_to_users_list(message)
  end
  
  
  #Modify a User
  #This method simple looks in db for the user to 
  #display in the form
  def modify_user  
    logger.info("-------------------Called modyfy user with id: "+params[:id])
    @user = User.find(params[:id])
  end
  
  #view a user
  def view_user
    @user = User.find(params[:id])
  end
  
  #update the information of a user
  def update_user
    logger.info("Updating user "+params[:id])
    @user = User.find(params[:id])
    #if users send the password blank is because 
    #he/she don't wnat to update it
    #in such cases we'll set the old passord
    user_from_form = params[:user]
    new_password = user_from_form[:password]
    if new_password.blank?
      logger.info("Password is blank. Will not update the password")
      params[:user].delete('password')
      params[:user].delete('password_confirmation')
      
    else
      logger.info("New Password: "+user_from_form[:password])
    end
    
    if @user.update_attributes(params[:user])
      redirect_to_users_list("User was #{@user.screen_name} successfully updated.")
    else
      logger.info("Updating user ERROR "+params[:id])
      render :action => 'modify_user'#, :id =>params[:id]
    end
  end
  
  #add a user
  def add_user
    if request.get?
      @user = User.new
    else
      @user = User.new(params[:user])
      if @user.save
        redirect_to_users_list "User created with sucess"
      end
    end
    
  end
  
  #list usesr
  def list_users
    @users = User.find(:all)
  end
  
  
  private
  def redirect_to_users_list(message) 
    flash[:notice] = message
    redirect_to :controller => "User", :action=>"list_users"
  end
end
