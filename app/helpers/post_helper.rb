
module PostHelper
  
  
  def render_linkable_tag_to_add_filter
    
    the_order = session[:the_active_order_for_label_new_channel]
    show_what = session[:the_active_filter_for_label_new_channel]
    
    
    if the_order.nil?
      the_order = "freq"
      session[:the_active_order_for_label_new_channel] = the_order
    end

    if show_what.nil?
      show_what = "all"
      session[:the_active_filter_for_label_new_channel] = show_what
    end

    
    #the_order = "freq"
    #show_what = "all"
    
    if params[:order]
      if params[:order] == "freq" || params[:order] == "alpha"
        the_order = params[:order]
        session[:the_active_order_for_label_new_channel] = the_order
      end
    end
    
    
    if params[:show]
      if params[:show] == "all" || params[:show] == "network"
        show_what = params[:show]
        session[:the_active_filter_for_label_new_channel] = show_what
      end
    end
    
    
    
    
    
    if the_order == "freq"
      order_clause = "label_count DESC" 
    else
      order_clause = "name ASC"
    end
    html = ""
    javascript_array =""
    
    tags = nil
    if show_what == "network" && session[:logged_user]
       tags = Label.get_friends_tag(session[:logged_user],true,nil,the_order)
    else
      tags = Label.find(:all, :order=>order_clause)
    end
    i = 0;
    tags.each do |tag|
      size = (100 + 2*tag.label_count)
      if size > 200
        size = 200
      end
      i = i+1
     
    
      javascript_array << "the_tag_#{tag.id}: '#{tag.name}'"
      
      if i != tags.size()
         javascript_array << ", "
      end
      
      html << "<a title=\"#{tag.label_count}\" id=\"the_tag_#{tag.id}\"  style=\"font-size:#{size}%\" href=\"javascript:addTag('the_tag_#{tag.id}')\" rel=\"tag\">#{tag.name}</a> "
    end
    #update javascrtip array
    #logger.info(javascript_array)  
    return [html,javascript_array]
  end
  
  
  
  def render_popular_links()
    html = ""
    pop_posts = UserPostV.find(:all, :conditions=>["original=1"], :order=>["rank DESC"], :limit=>10)
    
    pop_posts.each do |post|
      the_url = post_url(:permalink=>post.permalink)
     
           
      html << "<div class=\"small_title_in_box\"><a href=\"#{the_url}\">#{truncate(post.title, 45)}</a></div>"
      
     
      

      
      
      
    end
    html
    
    #:user_post_v, :per_page=>10, :conditions=>[conditions_text,condition_params], :order=>order_clause)  
    
  end
  
  def get_user_labels(post_id)
    
    #verify if any tag is selected
    post_filter = session[:post_filter]
    selected_tags = nil
    
    if !post_filter.nil? && !post_filter.tags.nil? 
      selected_tags = post_filter.tags
    end
    html = ""
    post = Post.find(post_id)
    labels = post.labels
    labels.each do |label|
      
      class_name = ""
      if !selected_tags.nil?
        selected_tags.each do |sel_tag|
          
          if sel_tag.upcase == label.name.upcase 
            class_name = "class=\"highlight_sel_tag\""
          end
        end
      end
      
      url = usertag_url(:user_screen_name=>post.user.screen_name,:label=>label.name)
      html += "<a #{class_name} href=\"#{url}\" title=\"#{label.name}\" rel=\"tag\">"+label.name+"</a> "
    end
    html
  end
  
  def get_user_cats(post_id)
    html = ""
    post_filter = session[:post_filter]
    selected_cats = nil
    
    if !post_filter.nil? && !post_filter.cats.nil? 
      selected_cats = post_filter.cats
    end
    post = Post.find(post_id)
    cats = post.categories
    cats.each do |cat|
      class_name = ""
      if !selected_cats.nil?
        selected_cats.each do |sel_cat|
          
          if sel_cat.upcase == cat.name.upcase 
            class_name = "class=\"highlight_sel_tag\""
          end
        end
      end
      
      url = usercategory_url(:user_screen_name=>post.user.screen_name,:category=>cat.name)
      html += "<a #{class_name} href=\"#{url}\" title=\"#{cat.name}\" rel=\"tag\">"+cat.name+"</a> "
    end
    html
  end
  
  def get_categories_names(link_url)
    html = ""
    
    categories = CategoriesPerUrl.find(:all, :conditions=>["link_url=?", link_url],:group=>"name")
    
    categories.each do |cat|
      url = category_url(:category=>cat.name)
      html +="<a title=\"Ver todos os links em #{cat.name}\"href=\"#{url}\" rel=\"tag\">"+cat.name+"</a>&nbsp;&nbsp;"
    end
    
    html 
  end
  
  def render_saved_by(saved_by)
    user_plural = "utilizador"
    if saved_by.to_i > 1
      user_plural = "utilizadores"  
    end
    html = ""
    html +="Submetido por #{saved_by} #{user_plural}"
    html 
    
  end
  def pluralize_votes(votes)
    if votes.to_i == 1
      return "voto"
    else
      return "votos"
    end
  end
  def pluralize_times(num) 
    html = "vezes"
    if num == 1
      html = "vez"
    end
    html
  end
  def get_all_labels(the_url, user_network_context = false)
    ret = ""
    
    #get filter from session
    
    filter = session[:post_filter]
    selected_tags = nil 
    
    if user_network_context
      session_filter = SessionFilter.get_from_session(session)
      selected_tags = session_filter.user_friend_network_tag
    else
      if !filter.nil?
        selected_tags = filter.tags_fp
      end
      
    end
    
    
    array = LabelsPerUrl.find(:all, :conditions=>["link_url=?",the_url], :group=>"name")
    unless array.nil?
      array.each do |label|
        
        #check if its selected
        additional_class = ""
        if !selected_tags.nil?
          selected_tags.each do |sel_tag|
            if sel_tag.upcase == label.name.upcase
              additional_class = "class=\"highlight_sel_tag\""
              break
            end
          end
        end
        
        fontsize = 99 + (label.label_count*2)
        
        if (fontsize > 115 ) 
          fontw = "bold"
        else
          fontw  = "normal"
        end
        if fontsize > 120
          fontsize = 120
        end
        url =""
        if user_network_context
          url = usernetworktag_url(:user_screen_name=>@user.screen_name, :label=>label.name)
        else
          url = "/tag/#{label.name}"
          #url = tag_url(:label=>label.name)
        end
        
        ret+="<a #{additional_class} title=\"Aplicada #{label.label_count} #{pluralize_times(label.label_count)}\" href=\"#{url}\" style='font-size:#{fontsize}%; font-weight:#{fontw}' rel=\"tag\">"+label.name+"</a>&nbsp; "
      end
    end 
    ret
  end
  
  def render_categories()
    cats = Category.get_all
    html = "<div class=\"multi_option_box\">"
    i = 0;
    
    
    
    cats.each do |cat|
      i += 1
      
      html += "<a id='#{cat.id}' href=\"javascript:swapCat('#{cat.id}')\" rel=\"tag\">#{cat.name}</a>"
      html +=  "&nbsp;&nbsp;"     
    end
    html += "</div>"
    html
  end
  
  def render_linkable_tags(tags_array)
    html =""
    
    
    tags_array.each do |tag| 
      html +="<a id=\"#{tag[:tag_key]}\" href=\"javascript:addTag('#{tag[:tag_key]}')\" rel=\"tag\"\">#{tag[:tag]}</a>"
      html +=" "
      
    end
    
    html
  end
  
  

  def build_javascript_hash_map_for_ex(tags)
    html =""
    size = tags.size
    i = 0
    tags.each do |tag|
      i = i+1
      html +="'the_tag_#{tag.id}': '#{tag.name}'"
      if i != size
        html +=", "
      end
    end

    html
  end


  def build_javascript_hash_map_for(tags_array)
    html =""
    size = tags_array.size
    i = 0
    tags_array.each do |tag|
      i = i+1
      html +="#{tag[:tag_key]}: '#{tag[:tag]}'"
      if i != size
        html +=", "
      end
    end
    html
  end
  
  
  def render_post_tabs(post)
    
    link_1 = link_to "Quem partilha este link?", savedby_url(:permalink=>post.permalink)
    link_2 = link_to "#{post.comments.count}&nbsp;#{pluralize_comments(post.comments.count)}", post_url(:permalink=>post.permalink)
    link_3 = link_to "Quem votou neste link?", votedby_url(:permalink=>post.permalink)
    html = ""
    html << "<div id=\"sub-nav\" style=\"font-size:110%;font-weight:bold\"><ul>"
    if @menu_active == "show_comments" 
      
      html << "<li class=\"active sub-comments\"><span id=\"number_of_comments_#{post.id}\">#{post.comments.count}&nbsp;#{pluralize_comments(post.comments.count)}</span></li>"
    else
      html << "<li>#{link_2}</li>"
    end
    if @menu_active == "who_saved" 
      html << "<li class=\"active sub-savedby\"><span>Quem partilha este link?</span></li>"
    else
      html << "<li>#{link_1}</li>"
    end
    if @menu_active == "who_voted" 
      html << "<li class=\"active sub-votedby\"><span>Quem votou neste link?</span></li>"
    else
      html <<  "<li>#{link_3}</li>"
    end
      html << "</ul><br /></div>"
    html
  end
  
  
end
