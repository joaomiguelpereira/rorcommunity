
class SessionFilter
  
  attr_accessor :user_friend_tag_cloud_order
  attr_accessor :user_friend_tag_cloud_type
  attr_accessor :user_friend_network_tag
  attr_accessor :user_friend_network_tag_operator
  
  
  def self.get_from_session(session)
    
    instance = session[:user_network_post_filter]
    
    if instance.nil?
      instance = SessionFilter.new
      
      session[:user_network_post_filter] = instance
    end
    
    return instance
    
  end
  
  def add_tag(tag_name)
    #this hack is not needed
    #the ack is here because dev only
    
    #if self.user_friend_network_tag.nil?
    #  self.user_friend_network_tag = Array.new
    #end
    
    if self.user_friend_network_tag.include?(tag_name)
      self.user_friend_network_tag.delete(tag_name)
    else
      self.user_friend_network_tag << tag_name
    end
  end
  
  def update_tags_operator(new_op)
    
    if new_op == "1" || new_op == "2"
      if new_op == "2"
        self.user_friend_network_tag_operator = "AND"   
      else
        self.user_friend_network_tag_operator = "OR"
      end
      
    end  
  end
  
  def update_from_params(params,session)
    
    #if params[:label] 
    #  self.add_tag(params[:label])
    #end
    
    
    
    
    if params[:tag_order]
      new_order = params[:tag_order]
      if new_order == "alpha" || new_order=="freq"
        the_order = 1
        
        if new_order == "alpha" 
          the_order = 2 
        end
        self.user_friend_tag_cloud_order = the_order   
        session[:user_network_post_filter] = self
      end
    end
    
    if params[:tag_type]
      new_type = params[:tag_type]
      if new_type == "list" || new_type=="cloud"
        the_type = 1
        
        if new_type == "list" 
          the_type = 2 
        end
        self.user_friend_tag_cloud_type = the_type   
        session[:user_network_post_filter] = self
      end
    end
    
  end
  
  def initialize
    self.user_friend_tag_cloud_order = 1
    self.user_friend_tag_cloud_type = 1
    
    self.user_friend_network_tag_operator = "OR"
    
    self.user_friend_network_tag = Array.new 
    
    super
  end
end