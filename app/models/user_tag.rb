class UserTag < ActiveRecord::Base
  belongs_to :user
  
  def self.delete_tag(tag_id)
    UserTag.destroy(tag_id)
  end  
  
  def self.find_user_tag(name)
    UserTag.find(:first, :conditions=>["name=?",name])
  end
  
  
  #MUDADO PARA Label Model
  def self.get_friends_tag(user_id, include_my_tags)
    #get all friends
    
    
    
    #"select * from user_tags where "
    conditions = ""
    if !include_my_tags
      conditions = "and user_id <> #{user_id}"
    end
    #sql = "select * from user_tags where user_id=#{user_id} or user_id in (select friend_id from user_friends where user_id=#{user_id}) group by name"
    sql = "select * from (select * from labels order by updated_at DESC limit 30) a where a.name in (select ut.name from user_tags ut where user_id=#{user_id} or user_id in (select friend_id from user_friends where user_id=#{user_id}) group by name)"
    


    #sql ="select * from user_tags where user_id in (select friend_id from user_friends uf where is_fan=0 and user_id=#{user_id}) group by name"
    
    #tags = Label.find_by_sql("select * from (select * from labels order by updated_at DESC limit 30) a order by #{order_clause}")
    
    friend_tags = UserTag.find_by_sql(sql)
    return friend_tags  
  end
  

end
