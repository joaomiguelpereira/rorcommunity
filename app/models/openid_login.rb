class OpenidLogin < ActiveRecord::Base
  
  def self.ishappening_login(openid_url)
    logger.info("IM HERE INSIDE---------------")
    login = OpenidLogin.find(:first, :conditions=>["open_id_url=?",openid_url])  
    
    if login
      return true
    end
    
    return false
  end
  
  def self.get_persistence_login_value(openid_url)
    login = OpenidLogin.find(:first, :conditions=>["open_id_url=?",openid_url])  

    if !login.nil?
      return login.persistent_login
    end
    return 0
  
  end
  def self.clear_login(openid_url)
    login = OpenidLogin.find(:first, :conditions=>["open_id_url=?",openid_url])  
    
    if login
    
      login.destroy
    end
    
  end
  
  def self.create_login(openid_url,persistence)
    login = OpenidLogin.new
    login.open_id_url = openid_url
    login.persistent_login = persistence
    login.create
    
  end
end
