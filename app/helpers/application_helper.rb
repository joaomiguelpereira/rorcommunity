# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def decode_html(text)
    html = text.gsub(/\n/, '<br />').gsub(/(http:\/\/[a-zA-Z\/.?;%]+)/, '<a rel="nofollow" target="_blank" href="1">\1</a>')
    html
  end
  def render_user_home_page_url(website)
    html = ""
    unless website.nil?
      html = "<a target=\"_blank\" href=\"#{website}\">(#{website})</a>"
    end
    html
    
  end
  def pluralize_links(links)
    text = ""
    if links == 1
      text ="link"
    else
      text ="links"
    end
    text
  end
  
  def pluralize_users(users)
    text = ""
    
    if users == 1
      text ="utilizador"
    else
      text ="utilizadores"
    end
    text
  end
  def pluralize_votes(votes)
    
    text = ""
    
    if votes == 1 || votes == -1
      text = "voto"
    else
      text = "votos"
    end
    text
    
  end
  
  def pluralize_comments(comments)
    html = "coment&aacute;rios"
    if comments == 1
      html = "coment&aacute;rio"
    end
    html
  end
  
  
  def render_html_class(votes)
    votes_class = "comment_votes"
    
    if votes < 0
      votes_class = "comment_votes_negative"
    end
    if votes > 0
      votes_class = "comment_votes_positive"
    end
    votes_class
    
  end
  
  def selected_menu
    
    session[:controller_name] = controller.controller_name
    session[:action_name] = controller.action_name
    logger.info("session[:controller_name]: "+session[:controller_name])
    logger.info("session[:action_name]: "+session[:action_name])
  end
  
  def include_scripts
    include = "";
    if session[:controller_name] == 'post' && session[:action_name] == 'view_post'
      #include = javascript_include_tag "tiny_mce/tiny_mce"
    end
    include 
  end  
  
  def include_css
    include = "";
    if session[:controller_name] == 'post' && session[:action_name] == 'view_post'
      
    end
    include 
  end
  def is_selected(menu_name) 
    
    
    if menu_name == 'profile' && session[:controller_name] == 'user'
      return true
    end
    return false
  end
  
  def render_small_user_image(user_image)
    if user_image.nil?
      return "??"
    end
    return user_image.small_url
  end
  
  def render_medium_user_image(user_image)
    if user_image.nil?
      return "??"
    end
    return user_image.medium_url
  end
  
  
  def to_day_month(date)
    return "??" if date.nil?
    months = Array.new
    months[1] = "Janeiro"
    months[2] = "Fevereiro"
    months[3] = "Mar&ccedil;o"
    months[4] = "Abril"
    months[5] = "Maio"
    months[6] = "Junho"
    months[7] = "Julho"
    months[8] = "Agosto"
    months[9] = "Setembro"
    months[10] = "Outubro"
    months[11] = "Novembro"
    months[11] = "Dezembro"
    
    
    html = date.day.to_s+" de "+months[date.month]+" de "+date.year.to_s
    
    
  end
  def to_day_month_abbr(date)
    if date.nil?
      return "??"
    end
    
    html = date.day.to_s+"/"+date.month.to_s+"/"+date.year.to_s
    
    
  end
  
  
  def date_formatter(date)
    html = "";
    html += distance_of_time_in_wordsEx(date)
  end
  
  def distance_of_time(from_date)
   
    seconds = (((Time.now - from_date).abs)).round
    minutes = (seconds/60).round
    hours = (minutes/60).round 
    days = (hours/24).round
    months = (days/30).round 
    years = (months/12).round
    
    
    
    minutes_ = minutes - (hours*60)
    hours_ = hours - (days*24)
    days_ = days - (hours*30) 
    
    "#{years} anos e #{months} meses #{days} dias #{hours_} horas #{minutes_} minutos e #{seconds}" 
  end
  def distance_of_time_in_wordsEx(from_time)
    logger.info("doing it here---1")
    if from_time.nil?
      return "0"
    end
    #logger.info("doing it here---from_time"+from_time)
    
    distance_in_minutes = (((Time.now - from_time).abs)/60).round
     logger.info("doing it here---2")
    distance_in_seconds = ((Time.now - from_time).abs).round
    case distance_in_minutes
    when 0..1
      
      case distance_in_seconds
      when 0..4   then 'menos de 5 segundos'
      when 5..9   then 'menos de 10 segundos'
      when 10..19 then 'menos de 20 segundos'
      when 20..39 then 'cerca de 30 segundos'
      when 40..59 then 'menos de 1 minuto'
      else             '1 minuto'
      end
      
    when 2..44           then "#{distance_in_minutes} minutos"
    when 45..89          then 'cerca de 1 hora'
    when 90..1439        then "cerca de #{(distance_in_minutes.to_f / 60.0).round} horas"
    when 1440..2879      then '1 dia'
    when 2880..43199     then "#{(distance_in_minutes / 1440).round} dias"
    when 43200..86399    then 'cerca de 1  m&ecirc;s'
    when 86400..525959   then "#{(distance_in_minutes / 43200).round} meses"
    when 525960..1051919 then 'cerca de 1 anos '
    else                      "mais de #{(distance_in_minutes / 525960).round} anos"
    end
  end
  
end


def friend_drop_menu(user, friend)
  
  html = "<div class=\"inline_menu\" id=\"user_option_div_#{friend.id}\" style=\"display:none;\">"
  
  remote_link_to_depromote = link_to_remote("Despromover", {:url=>{:controller=>"user", :action=>"promote_to_fan", :id=>@user.id,:fan_id=>friend.id },:loading=>"showWaiting()",:complete=>"hideWaiting()"},{:style=>"width:100px"})  
  html << "<ul>"
  html << "<li></li>"
  html << "<li>#{ remote_link_to_depromote}</li>"
  html << "<li><a style=\"width:100px\" href=\"#{userposts_url(:user_screen_name=>friend.screen_name)}\">Ver Links</a></li>"
  
  html << "<li><a style=\"width:100px\" href=\"#{usernetwork_url(:user_screen_name=>friend.screen_name)}\">Ver rede</a></li>"
  
  html << "</ul> </div>"
  html
  
end

def fan_drop_menu(user, fan)
  
  remote_link_to_accept = link_to_remote("Aceitar na Rede", {:url=>{:controller=>"user", :action=>"accept_friendship", :id=>@user.id,:fan_id=>fan.id },:loading=>"showWaiting()",:complete=>"hideWaiting()"},{:style=>"width:100px"})
  
  remote_link_to_reject = link_to_remote("Rejeitar na Rede", {:url=>{:controller=>"user", :action=>"refuse_friendship", :id=>@user.id,:fan_id=>fan.id },:loading=>"showWaiting()",:complete=>"hideWaiting()"},{:style=>"width:100px"})
  html = "<div class=\"inline_menu\" id=\"user_option_div_#{fan.id}\" style=\"display:none;\">"
  html << "<ul>"
  html << "<li></li>"
  html << "<li>#{remote_link_to_accept}</li>"
  html << "<li>#{remote_link_to_reject}</li>"
  
  
  html << "<li><a style=\"width:100px\" href=\"#{usernetwork_url(:user_screen_name=>fan.screen_name)}\">Ver rede</a></li>"
  
  html << "</ul> </div>"
  html
end

def user_drop_menu(user)
  html = "<div class=\"inline_menu\" id=\"user_option_div_#{user.id}\" style=\"display:none\">"
  html << "<ul>"
  html << "<li><a href=\"#{userposts_url(:user_screen_name=>user.screen_name)}\">Ver links</a></li>"
  html << "<li><a href=\"#{uservoted_url(:user_screen_name=>user.screen_name)}\">Listar links em que votou</a></li>"
  
  html << "<li><a href=\"#{user_url(:user_screen_name=>user.screen_name)}\">Consultar perfil</a></li>"
  html << "<li><a href=\"#{usernetwork_url(:user_screen_name=>user.screen_name)}\">Ver rede</a></li>"
  html << "<li><a href=\"\">Enviar mensagem</a></li>"
  #html << "<li><a href=\"javascript:void(0)\">Rank: #{user.rank}</a></li>"
  #html << "<li><a title=\"indica a data que este utilizador fez o &uacute;ltimo post, coment&aacute;rio ou voto\" href=\"javascript:void(0)\">#{to_day_month_abbr(user.last_activity)}</a></li>"
  
  
  
  html << "</ul> </div>"
  html
end

#override pagination helper
module ActionView
  module Helpers
    
    module PaginationHelper
      attr_accessor :is_ajax
      
      def pagination_links_ajax(paginator, options={}, html_options={})
        name = options[:name] || DEFAULT_OPTIONS[:name]
        params = (options[:params] || DEFAULT_OPTIONS[:params]).clone
        self.is_ajax = true;
        
        
        
        pagination_links_each(paginator, options) do |n|
          params[name] = n
          link_to(n.to_s, params, html_options)
        end
      end
      
      
      def pagination_links(paginator, options={}, html_options={})
        self.is_ajax = false;
        name = options[:name] || DEFAULT_OPTIONS[:name]
        params = (options[:params] || DEFAULT_OPTIONS[:params]).clone
        
        
        
        
        pagination_links_each(paginator, options) do |n|
          params[name] = n
          link_to(n.to_s, params, html_options)
        end
      end
      
      def pagination_links_each(paginator, options)
        
        options = DEFAULT_OPTIONS.merge(options)
        link_to_current_page = options[:link_to_current_page]
        always_show_anchors = options[:always_show_anchors]
        order = options[:params][:order]
        
        current_page = paginator.current_page
        window_pages = current_page.window(options[:window_size]).pages
        return if window_pages.length <= 1 unless link_to_current_page
        
        first, last = paginator.first, paginator.last
        
        html = ''
        if paginator.current.previous
          #html << '<span class="nextprev">'
          if self.is_ajax
            tmp = "<a href=\"javascript:void(0)\" onclick=\"users_table.changePage('#{paginator.current.previous.number}')\">&lt;&lt; Anterior</a>"
          else
            tmp =  link_to "&lt;&lt; Anterior", { :page => paginator.current.previous, :order=>order }
          end
          html << tmp
          #html << '</span>'
          
        end
        
        if always_show_anchors and not (wp_first = window_pages[0]).first?
          html << yield(first.number)
          html << '<span> ... </span>' if wp_first.number - first.number > 1
          html << ' '
        end
        
        window_pages.each do |page|
          if current_page == page && !link_to_current_page
            html << "<span class=\"current\">"+page.number.to_s+"</span>"
          else
            
            #tmp = "<a href=\"\" onclick=\"change_page('#{page.number}')\">#{page.number}</a>"
            
            if self.is_ajax
              html << "<a href=\"javascript:void(0)\" onclick=\"users_table.changePage('#{page.number}')\">#{page.number}</a>"
            else
              html << yield(page.number)
            end
          end
          html << ' '
        end
        
        if always_show_anchors and not (wp_last = window_pages[-1]).last? 
          html << '<span> ... </span>' if last.number - wp_last.number > 1
          html << yield(last.number)
        end
        if paginator.current.next
          if self.is_ajax
            tmp = "<a href=\"javascript:void(0)\" onclick=\"users_table.changePage('#{paginator.current.next.number}')\">Pr&oacute;xima &gt;&gt;</a>"    
          else
            tmp =  link_to "Pr&oacute;xima &gt;&gt;", { :page => paginator.current.next ,:order=>order}
          end
          
          html << tmp
        end
        
        html
        
        
        
      end
    end
  end
end
