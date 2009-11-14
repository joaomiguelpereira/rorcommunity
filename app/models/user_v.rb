class UserV < ActiveRecord::Base
  set_table_name "user_v"
  
  def user_image
    return UserImage.find(:first, :conditions=>["user_id=?",self.id])
  end
end
