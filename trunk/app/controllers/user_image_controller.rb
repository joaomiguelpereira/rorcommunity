class UserImageController < ApplicationController
  
  def upload_image
    #verify if the image is Ok?
    @file_image_data = params[:user_image][:file_image_data]
    
    extension = @file_image_data.original_filename.split('.').last.downcase
    #img = Magick::Image.read(@file_image_data)
    
    
    
    
    unless extension=='jpg' || extension=='png' || extension=='gif' || extension=='bmp'
      flash[:notice] = "Ficheiro inv&aacute;lido"
      redirect_to :controller=>"user", :action=>"change_photo"
      return
    end
    
    user_id = session[:logged_user]
    
    user = User.find(user_id)
    
    user_image = user.user_image
    
    user_image.extension = extension
    user_image.file_image_data = @file_image_data

    user_image.create_temp
    user_image.create_full_temp
    logger.info("IMG RATION: "+user_image.imgratio.to_s)
    user_image.update()
    
    
    
    #user_image.is_set = '1'
    #user_image.update()
    
    redirect_to :action=>"crop_image"
    
    rescue
      flash[:notice] = "Ficheiro inv&aacute;lido"
      redirect_to :controller=>"user", :action=>"change_photo"
      return    
  end
  def crop_and_save
    x = params[:crop_info][:x1]
    y = params[:crop_info][:y1]
    width = params[:crop_info][:width]
    heigh = params[:crop_info][:height]
    
    user_id = session[:logged_user]
    user = User.find(user_id)
    user_image = user.user_image
    
    user_image.create_images(x,y,width,heigh)
    
    user_image.update()
    user.profile_compteled = 1
    user.update()
    
    @new_url = user_image.medium_url
    #render :text=>"X #{x}, Y: #{y}, width:#{width}, heigh: #{heigh} "
  end
  def crop_image
    user_id = session[:logged_user]
    @user = User.find(user_id)    
    if @user.nil?
      logger.info("---------------------------------")
    end
    render :action=>"crop_image", :layout=>"upload_photo_layout"
  end
  
  def index
    #get images for the user
    #images = user.user_images
    #logger.info(images.size())
  end
end
