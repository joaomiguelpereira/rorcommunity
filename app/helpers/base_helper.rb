module BaseHelper
  def link_to_show_top_login_form
    if session[:logged_user]
      #link_to BaseHelper.get_message("login.login.logout"), {:controller =>:login, :action=>:logout},{:class=>"arrow_link"}
    else
      link_to_remote(BaseHelper.get_message("login.login.login"),
      {:url =>{:controller =>:login, :action=>:show_login_top_form},
        :loading => "showWaiting()",
        :complete => "hideWaiting()"},{:class=>"arrow_link"})
      
    end
  end
  
  def link_to_hide_top_login_form
    unless session[:logged_user]
      link_to_remote(BaseHelper.get_message("login.login.login"),
      {:url =>{:controller =>:login, :action=>:hide_login_top_form},
        :loading => "showWaiting()",
        :complete => "hideWaiting()"},{:class=>"arrow_link"})
    end
  end
  
  def self.get_message(key)
    Messages.messages[key]
  end
  
  
  def side_bar_container(title,id)
    html = ""
    html << "<div id=\"#{id}-title\" class=\"expandable-title-expanded\"><a href=\"javascript:void(0)\" onclick=\"show_hide_side_container('#{id}')\">#{title}</a></div><div id=\"#{id}\"><div id=\"#{id}-container\">"
    html
    
    
  end
  
  def end_side_bar_container
    html = ""
    html << "</div></div>"
    html
  end
  def drop_menu_option(url, title)
    html = ""  
    html << "<li><a style=\"width:100px\" href=\"#{url}\">#{title}</a></li>"
    html
  end
  def drop_menu(menu_id)
    html = ""
    html = "<div class=\"inline_menu\" id=\"#{menu_id}\" style=\"display:none\">"
    html << "<ul>"
        
    html
  end
  
  def end_drop_menu
    html = ""
    html << "</ul> </div>"
    html
  end
  
  def render_navigation
    html = ""
    #which the best way to do this????
    if session[:controller_name] == "post" && session[:action_name] == "front_page"
      html << "In&iacute;cio"
    else
      html << "<a href=\"\">In&iacute;cio</a>"
    end
    
    
    #html << " &raquo; "
    #html << "<a href=\"\">jocas 2</a>" 
    #html << " &raquo; " 
    #html << "Links submetidos ou gravados"
    html
  end
  def help_for(file, id)
    html = ""
    html +="<img alt=\"Ajuda online\" class=\"help_inline\" src=\"/images/help_inline.gif\" id=\""+id+"\" />"
    html +="<a dojoType=\"tooltip\" connectId=\""+id+"\" toggle=\"fade\" href=\"/help/"+file+".html\" executeScripts=\"true\"></a>"
    html   
  end  
  def error_messages(model_name)
    
    #    unless model_name
    #      return nil
    #    end
    return nil if model_name.nil?
    return nil if model_name.errors.nil?
    
    #return nil if model_name.errors.empty?
    flash[:notice] = BaseHelper.get_message("form.validation.error")
    return nil
  end
  
  def error_for(model_name, field_name)
    if model_name
      errors = model_name.errors[field_name]
      return nil if errors.nil?
      
      
      html = ""
      if errors.instance_of? Array
        for error in errors
          html += "<div class=\"fieldWithErrors\">"+error+"</div>"
        end
      else
        html = "<div class=\"fieldWithErrors\">"+errors+"</div>"
      end
    else
      html =""
    end
    html
  end
  
  def side_bar
    "<div class=\"sidebar\"> <div class=\"profile-right-box\" style=\"margin-top:20px\">"
  end
  
  
  def end_side_bar
    "</div></div>"
    
  end
  
  def render_front_page_extra_nav(where,text="")
    title = ""
    
   if where == "search"
      title = "<a href=\"/\">Blorkut</a> / pesquisa"
    end
    
    if where == "list_channels"
      title = "Canais"
    end
    
    if where == "view_channel"
      title = "Canais "+text
    end
    
    if where == "list_users"
      title = "Rede"
    end
    if where == "front_page"
      title = "Blorkut"
    end
    
    if where == "tag_cloud"
      title = "Tags"
    end
    
    
    html = ""
    
    html << "<div class=\"extra-nav\">"
    
    html << "<h2 style='margin-left:3px;'>#{title}</h2>"
    
    html << "<ul>"
    
    if where == "view_channel" || where == "list_channels"
      html << "<li class=\"active\"><span>Canais</span></li>"
    else
      html << "<li><a href=\"#{channels_url}\">Canais</a></li>"
    end
    
    
    if where == "list_users"
      html << "<li class=\"active\"><span>Rede</span></li>"
    else
      html << "<li><a href=\"#{users_url()}\">Rede</a></li>"
    end
    
    if where == "tag_cloud"
      html << "<li class=\"active\"><span>Tags</span></li>"
    else
      html << "<li><a href=\"#{tagcloud_url()}\">Tags</a></li>"
    end
    
    if where == "front_page" || where == "search" 
      html << "<li class=\"active\"><span>Blorkut</span></li>"
    else
      html << "<li><a href=\"#{home_url()}\">Blorkut</a></li>"
    end
    html << "</ul>"
    
    
    html << "</div>"
    html
    
  end
  
  def helper_for(what,id)
    html = ""
    

    title = "Mas o que e OpenId?"
    html << "<a href=\"javascript:void(0)\" onmouseout=\"mark_for_close('#{id}')\" onmouseover=\"open_helper(this,'#{id}','#{title}','#{what}')\" onmouseout=\"\" class=\"field_helper\">&nbsp;</a>"
    html
  end
  
end
