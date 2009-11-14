module HeaderHelper
  
  def render_categories
  
    #se estiver a ver no contexto de um utilizador, enta esquece isto
    
    
    #esta merda esta toda espalhado, n percebo nada disto, q se foda
    if session[:controller_name] == "user"  
      return ""
    end
    
    html = ""
    
    
    #i'm I seeing posts in user context
    html += "<li>"
    html += "<a class=\"current\" href=\"\">Todas</a>"
    html += "<li>"
    
    @cat_list.each do |category|
      the_url = category_url(:category=>category.name)
      html += "<li>"
      
      html += "<a href=\"#{the_url}\">#{category.name}</a>"
      
      #link_to category.name, {:controller=>"post", :action=>"show_category", :category=>category.id}#, {:class=>"current"}

      html += "</li>"
      html += " "
    end
   html
  end
end
