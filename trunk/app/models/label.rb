class Label < ActiveRecord::Base
  
  def self.get_by_name(tag)
    Label.find(:first, :conditions=>["name=?",tag])
  end
  
  
  def is_label_of_user(user_id) 
    
    sql = "select * from user_tags ut where (UPPER(ut.name)=UPPER(\"#{self.name}\")) and (user_id=#{user_id} or user_id in (select friend_id from user_friends where user_id=#{user_id})) group by name limit 1"
    
    user_tag = UserTag.find_by_sql(sql) 
    
    if !user_tag[0].nil? && user_tag[0].user_id == user_id
      return true
    end
    return false
  end
  
  def self.get_friends_tag(user_id, include_my_tags, user_current_network_filter, order_str=nil)
    #get all friends
    
    order_by = ""
    
    if !user_current_network_filter.nil?
      if user_current_network_filter.user_friend_tag_cloud_order == 1
        order_by = "order by label_count DESC"
      else
        order_by = "order by name ASC"
      end
    else
      
      if order_str == "freq"
        order_by = "order by label_count DESC" 
      else
        order_by = "order by name ASC"
      end
    end
    
    
    #"select * from user_tags where "
    
    conditions = ""
    if !include_my_tags
      conditions = "and user_id <> #{user_id}"
    end
    #sql = "select * from user_tags where user_id=#{user_id} or user_id in (select friend_id from user_friends where user_id=#{user_id}) group by name"
    sql = "select * from (select * from labels order by updated_at DESC limit 30) a where a.name in (select ut.name from user_tags ut where user_id=#{user_id} or user_id in (select friend_id from user_friends where user_id=#{user_id}) group by name) #{order_by} "
    
    
    
    #sql ="select * from user_tags where user_id in (select friend_id from user_friends uf where is_fan=0 and user_id=#{user_id}) group by name"
    
    #tags = Label.find_by_sql("select * from (select * from labels order by updated_at DESC limit 30) a order by #{order_clause}")
    
    friend_tags = Label.find_by_sql(sql)
    return friend_tags  
  end
  
  
  
end
