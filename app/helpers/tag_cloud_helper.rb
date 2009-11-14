module TagCloudHelper
  
  def render_all_tags(tags)
    html = ""
    tags.each do |tag|
      the_tag_url = tag_url(:label=>tag.name)
      f_size = (tag.label_count-1)*3+100
      
      if f_size > 250
        f_size = 250
      end 
         occu_txt = "Ocurr&ecirc;ncias"
      if tag.label_count == 1
        occu_txt = "Ocurr&ecirc;ncia"
      end
      html << "<a href=\"#{the_tag_url}\" style=\"font-size:#{f_size}%\" title=\"#{tag.label_count} #{occu_txt}\" rel=\"tag\">#{tag.name}</a> "
    end
    html
  end
  def front_page_most_recent_tags
    html = ""
    #get all 15 most active Tags, taht means that we must get them ordered by updated_at 
    #tags = Label.find(:all, :order=>"updated_at DESC")
    #if this is the first time running in the session
    type = 1
    order = 1
    if session[:tag_order_front_page].nil?
      session[:tag_order_front_page] = 1
      order = 1
    else
      order = session[:tag_order_front_page]
    end
    
    if session[:tag_cloud_type_front_page].nil?
      session[:tag_cloud_type_front_page] = 1
      type = 1
    else
      type = session[:tag_cloud_type_front_page]
    end
    
    filter = session[:post_filter]
    selected_tags = nil 
    
    if !filter.nil?
      selected_tags = filter.tags_fp
    end
    
    order_clause = ""
    if order ==1 
      order_clause = "label_count DESC"
      
    else
      order_clause = "name ASC"
    end
    tags = Label.find_by_sql("select * from (select * from labels order by updated_at DESC limit 30) a order by #{order_clause}")
    
    
    if type==2
      html << "<ul>"
    end
    
    tags.each do |tag|
      the_tag_url = tag_url(:label=>tag.name)
      f_size = (tag.label_count-1)*3+80
      
      if f_size > 210
        f_size = 210
      end 
      
      if type==2
        html << "<li>"
        html << " #{tag.label_count}&nbsp;&nbsp;"
      end
      additional_class = ""
      if !selected_tags.nil?
        selected_tags.each do |sel_tag|
          if sel_tag.upcase == tag.name.upcase
            additional_class = "class=\"highlight_sel_tag\""
            break
          end
        end
      end
      
      html << "<a #{additional_class} title=\"#{tag.name}\" href=\"#{the_tag_url}\"  style=\"font-size:#{f_size}%\" rel=\"tag\">#{tag.name}</a>"
      html << " "
      if type==2
        html << "</li>"
      end
      
    end
    
    if type==2
      html << "<ul>"
    end
    
    html
  end
  
  
  def tag_cloud_style_for_secondary_options
    if is_tag_cloud_visible
      "with_tag_cloud"
    else
      "no_tag_cloud"
    end
    
  end
  
  def render_cat_filtering(filter, screen_name)
    html = ""
    if filter.cats.nil?
      
      return ""
    end
    if filter.cats.size == 0
      return ""
    end
    
    if filter.cats.size > 1
      html << "Ver links nas categorias "
    end
    if filter.cats.size == 1
      html << "Ver links na categoria "
    end
    
    
    filter.cats.each do |cat|  
      the_url = usercategory_url(:user_screen_name=>screen_name,:category=>cat)
      html << "<a href=\"#{the_url}\" class=\"highlight_sel_tag\">"+cat+"</a> "
      
    end
    
    or_selected = ""
    and_selected = ""
    if filter.cats_operator == "OR"
      or_selected = " selected=\"selected\" "
    else
      and_selected = " selected=\"selected\" "
    end
    select = ""
    select = "<select name=\"cats_operator\" id=\"cats_operator\" class=\"select_box\" onchange=\"change_cats_operator()\">"
    select << "<option #{or_selected} value=\"1\">Ou</option>"
    select << "<option #{and_selected} value=\"2\">E</option>"
    select << "</select>"
    html << " . A usar #{select} como operador." 
    
    html
  end
  
  
  def render_tag_filtering(filter, screen_name)
    html = ""
    if filter.tags.nil?
      return "" 
    end
    
    if filter.tags.size == 0
      return ""
    end
    
    if filter.tags.size > 1
      html << "A filtrar pelas tags "
    end
    
    if filter.tags.size == 1
      html << "A filtrar pela tag "
    end
    
    
    
    filter.tags.each do |tag|
      if screen_name.nil?
        the_url = tag_url(:label=>tag)  
      else
        the_url = usertag_url(:user_screen_name=>screen_name,:label=>tag)
      end
      
      
      html << "<a href=\"#{the_url}\" class=\"highlight_sel_tag\"> rel=\"tag\""+tag+"</a> "
      
      
    end
    or_selected = ""
    and_selected = ""
    if filter.operator == "OR"
      or_selected = " selected=\"selected\" "
    else
      and_selected = " selected=\"selected\" "
    end
    select = ""
    select = "<select name=\"tags_operator\" id=\"tags_operator\" class=\"select_box\" onchange=\"change_tags_operator()\">"
    select << "<option #{or_selected} value=\"1\">Ou</option>"
    select << "<option #{and_selected} value=\"2\">E</option>"
    select << "</select>"
    html << " . A usar #{select} como operador." 
    return html
  end
  
  
  def render_tag_fp_filtering(filter)
    html = ""
    if filter.tags_fp.nil?
      return "" 
    end
    
    if filter.tags_fp.size == 0
      return ""
    end
    
    if filter.tags_fp.size > 1
      html << "A filtrar pelas tags "
    end
    
    if filter.tags_fp.size == 1
      html << "A filtrar pela tag "
    end
    
    
    
    filter.tags_fp.each do |tag|
      the_url = tag_url(:label=>tag)  
      
      
      html << "<a href=\"#{the_url}\" class=\"highlight_sel_tag\" rel=\"tag\">"+tag+"</a> "
      
      
    end
    or_selected = ""
    and_selected = ""
    if filter.tags_operator_op == "OR"
      or_selected = " selected=\"selected\" "
    else
      and_selected = " selected=\"selected\" "
    end
    select = ""
    select = "<select name=\"tags_operator\" id=\"tags_operator\" class=\"select_box\" onchange=\"change_tags_operator()\">"
    select << "<option #{or_selected} value=\"1\">Ou</option>"
    select << "<option #{and_selected} value=\"2\">E</option>"
    select << "</select>"
    html << " . A usar #{select} como operador." 
    return html
  end
  
  
  def render_tag_cloud_user(user, order, type)
    html = ""
    #get user preference related to tags
    
    #get filtering if any
    filter = session[:post_filter]
    selected_tags = nil 
    if !filter.nil?
      selected_tags = filter.tags
    end
    
    logged_user_id = session[:logged_user]
    
    if order.nil?
      session[:tag_order] = 1
    else
      session[:tag_order] = order
    end
    
    if type.nil?
      session[:tag_cloud_type] = 1
    else
      session[:tag_cloud_type] = type
    end
    
    tag_order = session[:tag_order]
    tag_cloud_type = session[:tag_cloud_type]
    
    #tag_order_req = params[:tag_order]
    #tag_cloud_type_req = params[:tag_cloud_type]
    
    
    if !logged_user_id.nil?
      
      logged_user = User.find(logged_user_id)
      user_prefs = logged_user.user_preference
      #If the logged user has no pref yet creat them
      
      if user_prefs.nil?
        user_prefs = UserPreference.new
        user_prefs.view_order = 1
        user_prefs.tag_cloud_order = tag_order
        user_prefs.tag_cloud_type = tag_cloud_type
        logged_user.user_preference = user_prefs
      else
        #if he/she have prefs already try to get what matters
        t_tag_order = user_prefs.tag_cloud_order
        
        if t_tag_order.nil?
          user_prefs.tag_cloud_order = tag_order
          
          logged_user.user_preference.update()
        else
          
          if t_tag_order != order && !order.nil? 
            user_prefs.tag_cloud_order = order 
            logged_user.user_preference.update()
            
            tag_order = order 
          end
          
          if order.nil?
            tag_order = user_prefs.tag_cloud_order
            session[:tag_order] = tag_order
          end
          
        end #else
        
        
        
        t_tag_cloud_type = user_prefs.tag_cloud_type
        if t_tag_cloud_type.nil?
          user_prefs.tag_cloud_type = tag_cloud_type
          
          logged_user.user_preference.update()
        else
          if t_tag_cloud_type != type && !type.nil?
            user_prefs.tag_cloud_type = type
            logged_user.user_preference.update()
            
            tag_cloud_type = type 
          end
          if type.nil?
            tag_cloud_type = user_prefs.tag_cloud_type
            session[:tag_cloud_type] = tag_cloud_type
          end
        end
      end  
    end
    
    
    order_clause = "name ASC"
    
    
    if tag_order == 2
      order_clause = "name ASC"
    end
    
    if tag_order == 1
      order_clause = "tag_count DESC"
    end
    
    
    if !user.nil? #not nil
      tags = UserTag.find(:all, :conditions=>["user_id = ?",user.id], :order=>order_clause)
    else
      tags = user.user_tags
    end
    
    if tag_cloud_type==2
      html << "<ul>"
    end
    
    tags.each do |tag|
      if !user.nil?
        the_tag_url = usertag_url(:user_screen_name=>user.screen_name, :label=>tag.name)
      else
        the_tag_url = tag_url(:label=>tag.name)
      end
      f_size = (tag.tag_count-1)*3+80
      
      if f_size > 210
        f_size = 210
      end 
      if tag_cloud_type==2
        html << "<li>"  
        
        
        html << " #{tag.tag_count}&nbsp;&nbsp;"
      end
      additional_class = ""
      if !selected_tags.nil?
        selected_tags.each do |sel_tag|
          if sel_tag.upcase == tag.name.upcase
            additional_class = "class=\"highlight_sel_tag\""
            break
          end
        end
      end
      
      
      html << "<a title=\"#{tag.name}\" href=\"#{the_tag_url}\" #{additional_class} style=\"font-size:#{f_size}%\" rel=\"tag\">#{tag.name}</a>"
      if tag_cloud_type==2
        html << "</li>"
      else
        html << " "
      end
      
    end
    
    if tag_cloud_type==2
      html << "</ul>"
    end
    html
  end
  
  def link_to_show_tag_cloud
    link_to_remote("&nbsp;",
    {:url =>{:controller =>:tag_cloud, :action=>:show_tag_cloud},
      :loading => "showWaiting()",
      :complete => "hideWaiting()"},
    {:class => "tagcloud"});
    
  end
  
  def link_to_hide_tag_cloud
    link_to_hide_tag_cloud_p(BaseHelper.get_message("header.secondary.hide_cloud"),"tagcloud")
  end
  
  
  def link_to_hide_tag_cloud_p(link_text, css_class)
    link_to_remote(link_text,
                   {:url =>{:controller =>:tag_cloud, :action=>:hide_tag_cloud},
      :loading => "showWaiting()",
      :complete => "hideWaiting()"},
    {:class =>css_class} );
  end
  
  def tag_cloud_show_hide
    if is_tag_cloud_visible
      link_to_hide_tag_cloud
    else
      link_to_show_tag_cloud
    end
  end
  
  def render_component_tag_cloud
    if is_tag_cloud_visible
      render_component(:controller =>"tag_cloud", :action=>"tag_cloud")
    end
  end
  
  
  def is_tag_cloud_visible
    
    if session["tag_cloud_visible"] && session["tag_cloud_visible"] == true
      true
    end
  end
end
