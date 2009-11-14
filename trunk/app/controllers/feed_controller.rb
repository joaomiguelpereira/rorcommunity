class FeedController < BaseController
  helper :post 
  
  def show_channel
    feed_permalink = params[:permalink]
    @user_channel = nil
    
    
    if feed_permalink
      @user_channel = UserChannel.find(:first, :conditions=>["permalink=?",feed_permalink])
    end
    if @user_channel 
      #get the order
      
      where = @user_channel.where_clause
      
      
      
      @post_pages, @posts = paginate("user_post_v", :per_page=>10,:conditions=>where, :order=>@user_channel.order_clause)
      
    else
      redirect_to not_found_url
    end
  end
  def list_channels
    
    @order = 1
    
    order = params[:order]
    where_clause = "1=1"
    if order
      if order == "2"
        @order = 2  
      else
        @order = 1  
      end
    end
    @user_filter = nil
    
    if !params[:user_screen_name].nil?
      @user_fitler = params[:user_screen_name]
      logger.info("-------------------------the user i s: лллллллллллллллллллллллллллллллллл "+@user_fitler)
      user_id = User.find(:first, :conditions=>["screen_name=?",@user_fitler])
      where_clause += " and user_screen_name = #{ActiveRecord::Base.connection.quote(@user_fitler)}" 
    end
    
    order_clause = "created_at ASC"
    if @order==1
      order_clause = "created_at DESC"  
    end
    
    @feed_pages, @feeds = paginate("user_channels",:per_page=>15,:order=>order_clause,:conditions=>where_clause)
    
  end
  
  def show_feed
    feed_permalink = params[:permalink]
    user_channel = nil
    
    if feed_permalink
      user_channel = UserChannel.find(:first, :conditions=>["permalink=?",feed_permalink])
    end
    
    if user_channel
      #get the weher clause
      @channel_name = user_channel.name
      @user_name = "desconhecido"
      if user_channel.user_id > 0
        user = User.find(user_channel.user_id)
        @user_name = user.screen_name 
      end
      
      @posts = UserPostV.find(:all, :conditions=>user_channel.where_clause, :order=>user_channel.order_clause,:limit=>50)
    end
    render :action=>"show_feed", :layout=>false
  end
  
  
end
