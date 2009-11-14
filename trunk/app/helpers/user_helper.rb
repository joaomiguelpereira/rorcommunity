module UserHelper
  
  
  def navigation_user_profile(section,user)
    
    user_name = user.screen_name
    
    title = ""
    if section =="view_user_posts_votes"
      title = "Links em que votou"
    end
    if section == "view_user_posts"
      title = "Links submetidos ou gravados"
    end
    
    if section == "view_public_profile"
      title = "Perfil"
    end
    if section == "personal_info"
      title = "Editar Perfil"
    end
    if section == "user_network"
      title = "Rede amigos"
    end
    
    html = ""
    #html += "<h1 class=\"big\">Editar perfil ("+@user.email+")</h1>"
    #html += "<div id=\"user_profile_photo\" style='background: url(#{user.user_image.medium_url}) no-repeat;width:60px;height:60px; float:left'>&nbsp;</div><div class=\"extra-nav\" style='float:left; width:100%;'>"
    html += "<div id=\"user_profile_photo\" style='background: url(#{render_medium_user_image(user.user_image)}) no-repeat;width:60px;height:60px; float:left'></div>"
    html += "<div class=\"user_screen_name\">#{user_name}</div>"
    html += "<div class=\"extra-nav\">"
    #<img src=\"#{image_url}\"/>
    
    html += "<h2 style='margin-left:3px;'>"+title+"</h2>"
    html += "<ul>"
    
    
    if section =="user_network"
      
      html += "<li class=\"active sub-voted\"><span>Rede amigos</span></li>"
    else
      html += "<li><a href=\"#{usernetwork_url(:user_screen_name=>user_name)}\">Rede amigos</a></li>"
    end
    
    
    
    if section =="view_user_posts_votes"
      
      html += "<li class=\"active sub-voted\"><span>Links em que votou</span></li>"
    else
      html += "<li><a href=\"#{uservoted_url(:user_screen_name=>user_name)}\">Links em que votou</a></li>"
    end
    
    if section == "view_user_posts"
      html += "<li class=\"active sub-submited\"><span>Links submetidos ou Gravados</span></li>"
      
    else
      
      #link_submited = link_to "Links submetidos", :controller=>"user", :action=>"user_posts", :id=>user.id
      link_submited = link_to "Links submetidos ou Gravados", userposts_url(:user_screen_name=>user.screen_name)
      html += "<li>#{link_submited}</li>"
      
    end    
    
    if session[:logged_user] && session[:logged_user].to_s == user.id.to_s 
      
      if section == "personal_info"
        html += "<li class=\"active\"><span>Editar perfil</span></li>"
      else
        link = link_to "Editar Perfil", :controller=>"user", :action=>"edit_profile"
        html += "<li>#{link}</li>"
      end
    end
    if section == "view_public_profile"
      html += "<li class=\"active sub-profile\"><span>Perfil</span></li>"
    else
      link = user_url(:user_screen_name=>user_name)
      html += "<li><a href=\"#{link}\">Perfil</a></li>"
      
    end
    html += "</ul>"
    html +="<br /></div><br />"
    html
    
  end
  def render_user_network_tag_filtering()
    
    user_current_network_filter = SessionFilter.get_from_session(session)
    
    
    html = ""
    
    if user_current_network_filter.user_friend_network_tag.size == 0
      return ""
    end
    
    if user_current_network_filter.user_friend_network_tag.size > 1
      html << "A filtrar pelas tags "
    end
    
    if user_current_network_filter.user_friend_network_tag.size == 1
      html << "A filtrar pela tag "
    end
    
    
    
    
    user_current_network_filter.user_friend_network_tag.each do |tag|
      
      the_tag_url = usernetworktag_url(:user_screen_name=>@user.screen_name, :label=>tag)
      html << "<a class=\"highlight_sel_tag\" title=\"#{tag}\" href=\"#{the_tag_url}\">#{tag}</a> "
     #html << tag
    end
   
    or_selected = ""
    and_selected = ""
    
    
    if user_current_network_filter.user_friend_network_tag_operator == "OR"
      or_selected = " selected=\"selected\" "
    else
      and_selected = " selected=\"selected\" "
    end
    
    select = ""
    #select = "<select name=\"nw_tags_operator\" id=\"nw_tags_operator\" class=\"select_box\" onchange=\"change_nw_tags_operator()\">"
    select = "<select name=\"tags_operator\" id=\"tags_operator\" class=\"select_box\" onchange=\"change_tags_operator()\">"
    select << "<option #{or_selected} value=\"1\">Ou</option>"
    select << "<option #{and_selected} value=\"2\">E</option>"
    select << "</select>"
    html << " . A usar #{select} como operador." 
    
    
    html
    
  end
  def render_user_friend_tags(user)
    html = ""
    
    user_current_network_filter = SessionFilter.get_from_session(session)
    user_current_network_filter.update_from_params(params, session)
    
    friend_tags = Label.get_friends_tag(user.id, true, user_current_network_filter)
    
    if user_current_network_filter.user_friend_tag_cloud_type == 2
      html << "<ul>"    
    end
    
    friend_tags.each do |tag| 
      
      is_being_filtered = ""
      if user_current_network_filter.user_friend_network_tag.include?(tag.name)
        
        is_being_filtered = "highlight_sel_tag"  
      end
      
      if user_current_network_filter.user_friend_tag_cloud_type == 2
        html << "<li>"    
      end
      
      the_tag_url = usernetworktag_url(:user_screen_name=>@user.screen_name, :label=>tag.name)
      
      f_size = (tag.label_count-1)*3+80
      
      if f_size > 210
        f_size = 210
      end 
      
      
      clazz = "friend_tag"
      
      if tag.is_label_of_user(@user.id)
        clazz = "user_tag"
      else
        clazz ="friend_tag"
      end
      #logger.info("Tag.user_id: #{tag.user_id} -- user_id =#{user_id}")
      html = html +  "<span class=\""
      html = html + clazz
      html = html + "\" id=\"friends_cloud_tag_"
      html = html + tag.id.to_s
      html = html +  "\">" 
      
      if user_current_network_filter.user_friend_tag_cloud_type == 2
        html << " #{tag.label_count} "    
      end
      html << "<a class=\"#{is_being_filtered}\" style=\"font-size:#{f_size}%\" href=\"#{the_tag_url}\" onclick=\"_do_clientCall( 'highlightFriendTagLink','#{tag.id}')\">#{tag.name}</a> </span>" 
      html = html + "\n"
      #logger.info("Tag.id: #{tag.id}")
      #logger.info("<span class=\"#{clazz}\" id=\"friends_cloud_tag_#{tag.id}\"> <a href=\"javascript:void(0)\" onclick=\"_do_clientCall( 'highlightFriendTagLink','#{tag.id}')\">#{tag.name}</a> </span>")
      #logger.info(html)
      #html << "<a href=\"javascript:void(0)\" onclick=\"_do_clientCall('highlightFriendTag('#{tag.name'})' );\">#{tag.name}</a> "
      if user_current_network_filter.user_friend_tag_cloud_type == 2
        html << "</li>"    
      end
      
    end
    if user_current_network_filter.user_friend_tag_cloud_type == 2
      html << "</ul>"    
    end
    
    html
    
    
  end
end
