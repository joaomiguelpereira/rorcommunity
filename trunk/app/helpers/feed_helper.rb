module FeedHelper
  
  def render_user_top_channels(user_id)
    
    #get all user channels
    channels = UserChannel.find(:all, :conditions=>["user_id=?",user_id],:order=>"created_at DESC", :limit=>"10")
    count = UserChannel.count()
    
    html = "<ul class=\"boxed_link\">"
    drop_down_html = ""  
    channels.each do |channel|
      user_name = "desconhecido"
      if channel.user_id > 0
        user = User.find(channel.user_id)
        user_name = user.screen_name
      end
      #url = personalized_rss_url(:permalink=>channel.permalink,:user_screen_name=>user_name)
      url = channel_url(:user_screen_name=>user_name,:permalink=>channel.permalink)
      
      html << "<li title=\"teste\"><a href=\"#{url}\">#{truncate(channel.name,30)}</a><a id=\"#{channel.permalink}\" href=\"javascript:void(0)\" onclick=\"open_feed_context_menu(this)\">&raquo;</a></li>"
      
      drop_down_html << dropdown_feed_option(channel,user_name)
      
    end
    
    if count > 10
      url = channels_url
      html << "<li><a href=\"#{url}\">ver todos</a></li>"
    end
    html << "<ul>"
    html << drop_down_html
    
    html
  end
  
  def list_channels_ordering_options
    html = ""
    
    if @order == 1
      html << "<span class=\"tool selected\">Mais recentes</span>"
    else
      html << "<span class=\"tool\"><a href=\"#{channels_url}?order=1\">Mais recentes</a></span>"
    end
    
    if @order == 2
      html << "<span class=\"tool selected\">Mais antigos</span>"  
    else
      html << "<span class=\"tool\"><a href=\"#{channels_url}?order=2\">Mais antigos</a></span>"
    end
    
    html
  end
  
  def feed_summary(user_channel)
    user_home_url = ""
    if user_channel.user_id > 0
      user_home_url = user_url(:user_screen_name=>user_channel.user_screen_name)  
    end
    
    html = "Canal criado em <em>#{to_day_month(user_channel.created_at)}</em> por <a href=\"#{user_home_url}\">#{user_channel.user_screen_name}</a>."
    
    html << "Todos os posts"
    
    if user_channel.order_by == "Mais recentes"
      html << " mais recentes"
    end
    
    if user_channel.order_by == "Populares"
      html << " mais populares"
      if user_channel.limit_popular_by == "Top 24 horas"
        html << " das &uacute;ltimas 24 horas"
      end
      
      if user_channel.limit_popular_by == "Top 7 dias"
        html << " dos &uacute;ltimos 7 dias"
      end
      
      if user_channel.limit_popular_by == "Top 30 dias"
        html << " dos &uacute;ltimos 30 dias"
      end
      
      if user_channel.limit_popular_by == "Top 365 dias"
        html << " dos &uacute;ltimos 365 dias"
      end
      
    end
    
    if user_channel.order_by == "Menos populares"
      html << " menos populares"
    end
    
    #get the tags
    if !user_channel.filter_tags.nil?
      tags = user_channel.filter_tags.split(" ")
      
      if tags.size == 1
        html << " com a tag"
      end
      
      if tags.size > 1
        html << " com as tags"
      end
      count = 0
      tags.each do |tag|
        count += 1
        tag_url = tag_url(:label=>tag)
        html <<  " <a href=\"#{tag_url}\" rel=\"tag\">#{tag}</a>"
        
        if count < tags.size
          if user_channel.tags_operator == "1"
            html <<  " ou"
          else
            html <<  " e"
          end
        end
      end
      
    end
    
    if !user_channel.user_groups.nil?
      if user_channel.user_groups == "[ todos ]"
        html << " de toda rede"    
      end 
      
      if user_channel.user_groups == "[ toda a minha rede ]"
        html << " de toda a minha rede"     
      end
      
      
      if user_channel.user_groups != "[ toda a minha rede ]" && user_channel.user_groups != "[ todos ]"
        user_names =  user_channel.user_groups.split(" ")
        
        if user_names.size == 1
          html << " do utilizador"
        end
        
        if user_names.size > 1
          html << " dos utilizadores"
        end
        count = 0
        
        user_names.each do |user_name|
          count+=1
          home_url = user_url(:user_screen_name=>user_name)
          html << " <a href=\"#{home_url}\">#{user_name}</a>"
          if count < user_names.size
            html << " e"
          end
          
        end
      end
      
    end  
    html
  end
  
  def dropdown_feed_option (channel,screen_name)
    
    
    rss_channel_url = personalized_rss_url(:user_screen_name=>screen_name,:permalink=>channel.permalink)
    the_channel_url = channel_url(:user_screen_name=>screen_name,:permalink=>channel.permalink)
    html = "<div class=\"inline_menu darker\" id=\"channel_option_div_#{channel.permalink}\" style=\"display:none;\">"
    
    html << "<ul>"
    html << "<li></li>"
    
    html << "<li><a style=\"width:100px\" href=\"#{the_channel_url}\">Ver canal</a></li>"
    html << "<li><a style=\"width:100px\" href=\"#{rss_channel_url}\">Subscrever em RSS</a></li>"
    
    
    
    html << "</ul> </div>"
    html
  end
end
