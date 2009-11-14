class UserChannel < ActiveRecord::Base
  after_create :create_constants
  
  def create_constants
    
    
    #Create user name
    
    if self.user_id > 0
      
      user = User.find(self.user_id)
      self.user_screen_name = user.screen_name
    else
      self.user_screen_name = "desconhecido"
    end
    #get all labels if any
    labels = self.filter_tags.rstrip().lstrip().split(" ")
    
     
    conditions_text = "original=1"
    condition_params = Hash.new
    
   
    
    #start tags
    operator = "or"
    
    if self.tags_operator == "2"
      operator = "and"
    end
    
    if labels.size > 0 
      conditions_text << " and ("
    end
    
    count = 0
    
   
    labels.each do |label|
      count = count +1
      conditions_text << "url_has_label(link_url, #{ActiveRecord::Base.connection.quote(label)}) "
      #condition_params[:"label_#{count}"]= label
      if count != labels.size
        conditions_text << "#{operator} "
      end
      
    end
    
    if labels.size > 0
      conditions_text << ")"
    end  
    #end tags
    
    #########start user filtering
    if self.user_groups == "[ toda a minha rede ]"
      conditions_text << " and is_friend(user_id,#{self.user_id}, TRUE)"
    end
    
    if self.user_groups != "[ toda a minha rede ]" && self.user_groups != "[ todos ]"
      users = self.user_groups.rstrip().lstrip().split(" ")
      
      if users.size > 0
        conditions_text << " and ("
      end
      count = 0
      users.each do |user_name|
        count = count +1
        conditions_text  << "user_id = (select id from users where screen_name=#{ActiveRecord::Base.connection.quote(user_name)}) "
        if count != users.size
          conditions_text << "and "
        end
      end
      if users.size > 0
        conditions_text << ")"
      end
    end
    #########end users filtering
    
    ##Populares
    if self.order_by == "Populares"
      days = "1"
      
      if self.limit_popular_by == "Top 7 dias"
        days = "7"
      end

      if self.limit_popular_by == "Top 30 dias"
        days = "30"
      end

      if self.limit_popular_by == "Top 365 dias"
        days = "365"
      end
      conditions_text << "and DATE_SUB(CURDATE(),INTERVAL #{days} DAY) <= created_at "  
    end
    
    
    #conditions_text << "limit 50"
    
    ##End Populares
    
    ##start oder by
    order_clause = ""
    
    if self.order_by == "Populares"
      order_clause << "rank DESC"
    end

    if self.order_by == "Mais recentes"
      order_clause << "created_at DESC"
    end

    if self.order_by ==  "Menos populares"
      order_clause << "rank ASC"
    end
     
    ##end order by
    
    self.where_clause =  conditions_text
    self.order_clause = order_clause
    self.permalink = "feed_"+self.id.to_s
    self.update
  end
  
end
