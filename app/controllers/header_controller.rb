class HeaderController < ApplicationController
  helper :tag_cloud, :login
  
  def main_options
   
  end
  
  def side_options
  
  end
  
  def secondary_options
    @cat_list = Category.get_all
  end
  
  def side_box
    @box1 = false
    @box2 = false
    @box3 = false
    
    if session[:controller_name] == "post" && session[:action_name] == "front_page"
      @box1 = true
    end

    if session[:controller_name] == "post" && session[:action_name] == "view_post"
      @box2 = true
      #@box3 = true
    end

  end
 
end
