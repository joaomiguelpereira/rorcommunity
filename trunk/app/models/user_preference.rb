class UserPreference < ActiveRecord::Base
  
  
  
  def self.update_user_network_post_order(user_id, new_val)
    return  if user_id.nil?
    
    user_preference = UserPreference.find(:first, :conditions=>["user_id=?",user_id])
    
    if user_preference.nil?
      user_preference = UserPreference.new
      user_preference.user_id = user_id
      user_preference.view_order = 1
      user_preference.tag_cloud_order = 1
      user_preference.tag_cloud_type = 1
      user_preference.fp_ordering = 1
      user_preference.include_my_posts = 1
      user_preference.nw_post_order = new_val
      user_preference.save()
    else
      user_preference.nw_post_order = new_val
      user_preference.update()
    end
    
  end
  
  def self.get_user_network_post_order(user_id)
    
    user_preference = UserPreference.find(:first, :conditions=>["user_id=?",user_id])
    ret = 1
    
    if user_preference.nil?
      user_preference = UserPreference.new
      user_preference.user_id = user_id
      user_preference.view_order = 1
      user_preference.tag_cloud_order = 1
      user_preference.tag_cloud_type = 1
      user_preference.fp_ordering = 1
      user_preference.include_my_posts = 1
      user_preference.nw_post_order = 1
      user_preference.save()
    else
      ret = user_preference.nw_post_order 
      if ret.nil?
        user_preference.include_my_posts = 1
        user_preference.update()
      else
        ret = 1
      end
      
    end
    
  end
 
  def self.update_fp_order(user_id,new_order)
    return  if user_id.nil?
    user = UserPreference.find(:first, :conditions=>["user_id=?",user_id])
    return if user.nil?
    
    user.fp_ordering = new_order
    user.update()
  end
  
  def self.update_include_my_own_posts(user_id, new_val)
    
    user_preference = UserPreference.find(:first, :conditions=>["user_id=?",user_id])
    
    if user_preference.nil?
      user_preference = UserPreference.new
      user_preference.user_id = user_id
      user_preference.view_order = 1
      user_preference.tag_cloud_order = 1
      user_preference.tag_cloud_type = 1
      user_preference.fp_ordering = 1
      user_preference.include_my_posts = new_val
      user_preference.save()
    else
      user_preference.include_my_posts = new_val;
      user_preference.update()
    end
  end
  
  
  def self.get_include_my_own_posts(user_id)
    #find the user preference  
    user_preference = UserPreference.find(:first, :conditions=>["user_id=?",user_id])
    ret = 1
    if user_preference.nil?
      user_preference = UserPreference.new
      user_preference.user_id = user_id
      user_preference.view_order = 1
      user_preference.tag_cloud_order = 1
      user_preference.tag_cloud_type = 1
      user_preference.fp_ordering = 1
      user_preference.include_my_posts = 1
      user_preference.save()
    else
      ret = user_preference.include_my_posts
      if ret.nil?
        user_preference.include_my_posts = 1
        user_preference.update()
      else
        ret = 1
      end
    end
    
    ret
    
    
  end
  
  def self.get_fp_order(user_id)
    return nil if user_id.nil?
    
    user = UserPreference.find(:first, :conditions=>["user_id=?",user_id])
    
    return nil if user.nil?
    
    return user.fp_ordering 
  end
end
