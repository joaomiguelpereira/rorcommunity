class CommunityController < BaseController

  def index
    redirect_to :controller=>"post", :action=>"front_page"
  end
  
  def admin
  end
  def not_found
  
    response.headers["Status"] = "404"
  end
  
  def unknow_request
    redirect_to not_found_url
  end
  
 
end
