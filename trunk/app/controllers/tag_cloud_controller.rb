class TagCloudController < BaseController
 helper :post
 
 def tag_cloud
 
  order_req = params[:order]
  count_req = params[:count]
  
  big_tag_cloud_count = session[:big_tag_cloud_count]
  
  if big_tag_cloud_count.nil?
    session[:big_tag_cloud_count] = "50"
    big_tag_cloud_count = "50"
  else
    big_tag_cloud_count = session[:big_tag_cloud_count]
  end
  
  
  
  if !count_req.nil?
  
     big_tag_cloud_count = count_req
     session[:big_tag_cloud_count] = big_tag_cloud_count
  end
  
  #are you fooling me
  if big_tag_cloud_count != "20" && big_tag_cloud_count != "50" && big_tag_cloud_count != "100" && big_tag_cloud_count != "all"
    big_tag_cloud_count = "50"
    session[:big_tag_cloud_count] = big_tag_cloud_count
  end
  
  
  
  
  #try the session

  big_tag_cloud_order = session[:big_tag_cloud_order]
  if big_tag_cloud_order.nil?
    session[:big_tag_cloud_order] = "freq"
    big_tag_cloud_order = "freq"
  else
    big_tag_cloud_order = session[:big_tag_cloud_order]
  end
  
  if !order_req.nil?
  
     if order_req == "freq"
       big_tag_cloud_order = "freq"
     else
      big_tag_cloud_order = "alpha"
     end
     session[:big_tag_cloud_order] = big_tag_cloud_order
  end
  
  
  
  order_clause = "label_count DESC"
  
  if big_tag_cloud_order == "alpha"
    order_clause = "name ASC"
  end
  limit = 50
  if big_tag_cloud_count == "all"
    limit = 9999
  else
    limit = big_tag_cloud_count.to_i
  end
  
  @tags = Label.find(:all, :order=>order_clause, :limit=>limit)
 end
 
 def change_tag_cloud_type_front_page
   type = params[:type]
   order = params[:order]
   
   if !type.nil?
     if type == 'list'
       session[:tag_cloud_type_front_page] = 2
     else
      session[:tag_cloud_type_front_page] = 1
     end
   end
   
   if !order.nil?
     if order == 'alpha'
       session[:tag_order_front_page] = 2
     else
      session[:tag_order_front_page] = 1
     end
   end
   
   
 end
 
 def change_tag_cloud_type
  type = params[:type]
  user_id = params[:user_id]
  @the_type = 1
  
  if type.nil?
    @the_type = 1
  else
    if type == "list"
      @the_type = 2
    else
      @the_type = 1
    end
  end
  
  session[:tag_cloud_type] = @the_type
  
  if !user_id.nil?
    @user = User.find(user_id)
  else
    @user = nil
  end
  @order = session[:tag_order]
  
  logger.info("reorder called "+@the_type.to_s)
  logger.info("reorder called "+@order.to_s)
 end
 
 def reorder
  order = params[:order]
  user_id = params[:user_id]
  @the_order = 1
  
  if order.nil?
    @the_order = 1
  else
    if order == "alpha"
      @the_order = 2
    else
      @the_order = 1
    end
  end
  
  session[:tag_order] = @the_order
  
  if !user_id.nil?
    @user = User.find(user_id)
  else
    @user = nil
  end
  @type = session[:tag_cloud_type]
  

 end
 
 def show_tag_cloud
    session["tag_cloud_visible"] = true
  end
  
  def hide_tag_cloud
 
    #set the tag cloud invisible
    session["tag_cloud_visible"] = false
    #render nothing in the div
    #render :text =>""
  end
end
