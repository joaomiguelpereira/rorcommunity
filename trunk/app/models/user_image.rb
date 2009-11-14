require 'RMagick'

class UserImage < ActiveRecord::Base
  belongs_to :user
  
  
  DIRECTORY ='public/user_images'
  DEFAULT_IMAGE_DIRECTORY = 'public/user_images/default'
  MEDIUM_MAX_SIZE = [60,60]
  SMALL_MAX_SIZE = [32,32]
  FULL_MAX_SIZE = [96,96]
  MAX_WIDTH = 96
  MAX_HEIGHT = 96
  
  
  after_save :process
  after_update :process
  after_destroy :cleanup
  
  def file_image_data=(file_image_data)
    @file_image_data = file_image_data
    #write_attribute 'extension', file_image_data.original_filename.split('.').last.downcase
  end
  
  
  def self.create_default_image_for(user)
    user_image = self.new
    user_image.user = user
    user_image.is_set = '0'
    user_image.save()
  end
  
  def url
    path.sub(/^public/,'')
  end
  
  def full_temp_url
    full_temp_path.sub(/^public/,'')
  end
  
  def temp_url
    temp_path.sub(/^public/,'')
  end
  
  
  def medium_url
    medium_path.sub(/^public/,'')
  end
  
  def small_url
    small_path.sub(/^public/,'')
  end
  
  def path
    if self.is_set == '0'
      File.join(DEFAULT_IMAGE_DIRECTORY, "default.jpg")
    else
      File.join(DIRECTORY, "#{self.user.screen_name}/#{self.id}-full.#{self.extension}")
    end
  end
  
  
  def full_temp_path
    File.join(DIRECTORY, "#{self.user.screen_name}/temp/#{self.id}-full.#{self.extension}")
  end
  
  def medium_temp_path
    File.join(DIRECTORY, "#{self.user.screen_name}/temp/#{self.id}-medium.#{self.extension}")
  end
  
  def small_temp_path
    File.join(DIRECTORY, "#{self.user.screen_name}/temp/#{self.id}-small.#{self.extension}")
  end
  
  
  def temp_path
    
    File.join(DIRECTORY, "#{self.user.screen_name}/temp/#{self.id}-temp.#{self.extension}")
    
  end
  
  def medium_path
    if self.is_set == '0'
      File.join(DEFAULT_IMAGE_DIRECTORY, "default-medium.jpg")
    else
      logger.info self.user.screen_name
      File.join(DIRECTORY, "#{self.user.screen_name}/#{self.id}-medium.#{self.extension}")
    end
  end
  
  def small_path
    if self.is_set == '0'
      File.join(DEFAULT_IMAGE_DIRECTORY, "default-small.jpg")
    else
      File.join(DIRECTORY, "#{self.user.screen_name}/#{self.id}-small.#{self.extension}")
    end
  end
  
  def create_full_temp
    maxwidth = 220
    maxheight = 260
    aspectratio = maxwidth.to_f / maxheight.to_f
    
    img = Magick::Image.read(temp_path).first
    
    imgwidth = img.columns
    imgheight = img.rows
    



    thumb = img
    
    if imgwidth < 96 || imgheight < 96
      thumb = img.thumbnail(*FULL_MAX_SIZE)
    else if imgwidth > maxwidth || imgheight > maxheight
    
      imgratio = imgwidth.to_f / imgheight.to_f
      
      imgratio > aspectratio ? scaleratio = maxwidth.to_f / imgwidth : scaleratio = maxheight.to_f / imgheight
      self.imgratio = imgratio
      thumb = img.resize(scaleratio)

      white_bg = Magick::Image.new(maxwidth, thumb.rows)
      thumb = white_bg.composite(thumb, Magick::CenterGravity, Magick::OverCompositeOp)
    end
    
    end
    
    #se a imagem tiver < 96 de altura ou 96 de largura, fix para 96*96
    if thumb.columns < 96 || thumb.rows < 96
      thumb = img.thumbnail(*FULL_MAX_SIZE)
    end 
    #pic.write(imgfile + '.thumb.jpg')
    
    #medium = img.thumbnail(*MEDIUM_MAX_SIZE)
    thumb.write full_temp_path	  
  end
  
  def imgratio=(img_ration)
    @img_ration = img_ration
  end
  
  def imgratio
    @img_ration
  end
  
  def create_temp
    create_temp_directory
    cleanup_temp
    
    File.open(temp_path,'wb') do |file|
      file.puts @file_image_data.read
    end
  end
  
  def create_images(x,y, width, height)
    self.is_set = '1'
    cleanup
    
    img = Magick::Image.read(self.full_temp_path).first
    normal = img.crop(x.to_i,y.to_i,width.to_i,height.to_i)
    
    # normal = img.thumbnail(*FULL_MAX_SIZE)
    normal.write self.path	 
    create_medium
    create_small
    
    cleanup_temp 
  end
  
  #######
  private
  #######
  
  def process
    if self.is_set == '0'
      return
    end
    
    if @file_image_data
      #create_directory
      #cleanup
      #save_fullsize
      #create_medium
      #create_small
      
      
      
      @file_image_data = nil
    end
  end
  
  
  def save_fullsize
    File.open(path,'wb') do |file|
      file.puts @file_image_data.read
    end
  end
  
  def create_medium
    img = Magick::Image.read(path).first
    medium = img.thumbnail(*MEDIUM_MAX_SIZE)
    medium.write medium_path	  
  end
  
  def create_small
    img = Magick::Image.read(path).first
    small = img.thumbnail(*SMALL_MAX_SIZE)
    small.write small_path	  
  end
  
  
  def create_temp_directory
    FileUtils.mkdir_p DIRECTORY+"/"+self.user.screen_name+"/temp"
  end
  
  def cleanup_temp
    if self.is_set == '0'
      return
    end
    
    Dir[File.join(DIRECTORY, "#{self.user.screen_name}/temp/#{self.id}-*")].each do |filename|
      File.unlink(filename) rescue nil
    end
  end
  
  def create_directory
    FileUtils.mkdir_p DIRECTORY+"/"+self.user.screen_name
  end
  
  def cleanup
    if self.is_set == '0'
      return
    end
    
    Dir[File.join(DIRECTORY, "#{self.user.screen_name}/#{self.id}-*")].each do |filename|
      File.unlink(filename) rescue nil
    end
  end
  
end
