require 'uri'
require 'open-uri'
require 'hpricot'
require 'mofo'

class GoogleMapController < ApplicationController
  
  def map
    
    #local host
    @api_key = "ABQIAAAANg0812jNLLHg8BBhwilg9RTJQa0g3IQ9GZqIMmInSLzwtGDKaBTov460ZwsAvIxOZzOgEvqQBBjd6A"
    #find the user
    #logger(params[:user_id])
    user_id = params[:user_id]
    @read_only = params[:read_only]
    if @read_only.nil?
      @read_only = false
    else
      @read_only = true
    end
     
    user = User.find(user_id)
    @user_name = user.screen_name
    @has_point_defined = false
    
    unless user.gmap_lat.nil? && user.gmap_long.nil?
      @lat = user.gmap_lat
      @long = user.gmap_long
      @has_point_defined = true
    else
      @lat = "39.825413103424786"
      @long = "-8.59130859375"
      @zoom_level = "6" 
    end
    
    if !user.gmap_zoom_level.nil? && !user.gmap_zoom_level.empty?
      @zoom_level = user.gmap_zoom_level
    else
      @zoom_level = "6"
    end
    
    
    
    
  end
  
  def show_user_map
    
    
  end
  def hide_user_map
    
  end
  
  
  def reverse_geocoding
    @lat = params[:lat]
    @long = params[:long]
    @zoom_level = params[:zlevel]
    
    logger.info("Latitude: #{@lat} Longitude: #{@long} Zoom: #{@zoom_level}")
    the_url = "http://ws.geonames.org/findNearbyPlaceName?lat=#{@lat}&lng=#{@long}"
    location = get_location(the_url);
    @name = "desconhecido"
    @country = "desconhecido"
    if location.nil?
      logger.info("Nothing found")
    else
      @name = location[:name]
      @country = location[:country]
      
      #logger.info("Here it goes the country"+location[:country])
      #logger.info("Here it goes the name"+location[:name])
    end
    
  end
  
  private
  def get_location(the_url)
    
    #logger.info("---------------------")
    doc = Hpricot(open(the_url))
    #logger.info(doc)
    name_el = doc.search("name")
    countryname_el = doc.search("countryname")
    name = "desconhecido"
    country ="desconhecido"
    unless name_el.nil? 
      name = name_el.innerHTML
    end
    
    unless countryname_el.nil? 
      countryname = countryname_el.innerHTML
    end
    
    location = {:name=>name,:country=>countryname}
    location
  rescue
    return nil
    
  end
end
