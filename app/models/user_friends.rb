class UserFriends < ActiveRecord::Base
  
  def self.get_friends(user_id)
    friends = UserFriends.find(:all, :conditions=>["user_id=?",user_id])
    
    return friends 
  end
  
  def self.count_friends(user_id)
    sql = "select count(*) from user_friends where user_id=#{user_id}" 
    return UserFriends.count_by_sql(sql)
  end
  
  def get_friend_ship_with_parent(parent_id, parent_friends_id_list)
    
    #para cada amigo verificar se e amigo do pai
    friends = UserFriends.get_friends(self.friend_id)
    
    friends.each do |friend|
      logger.info "the friend of my parent is :"+friend.friend_id.to_s
      if (friend.user_id == parent_id )
        logger.info "This is my parent"
      end
    end
    
  end
  
  def self.get_friends(user)
    friends = UserFriends.find(:all, :conditions=>["user_id=? and is_fan=0",user])
    return friends
  end
  
  def self.get_friendship(user, friend)
    user_friend = UserFriends.find(:first, :conditions=>["user_id=? and friend_id=?",user,friend])
    
    if user_friend.nil?
      
      return -1
    end
    
    return user_friend.is_fan
    
  end
  
  def self.get_fans(user)
    fans = UserFriends.find(:all, :conditions=>["user_id=? and is_fan=1",user])
    return fans
  end
  
  
  def friend
    
    User.find(self.friend_id)
  end
  
  def self.is_fan_or_friend(user, friend)
    
    friend = UserFriends.find(:first, :conditions=>["user_id=? and friend_id=?",user,friend])
    if friend.nil?  
      return false
    else
      return true
    end
    
  end
  def self.promote_friend_to_fan(user, friend)
    sql = "update user_friends set is_fan = 1, friend_since = 0 where user_id=#{user} and friend_id=#{friend}"
    ActiveRecord::Base.connection.execute(sql)
    
    
  end
  def self.remove_friend(user,friend)
    sql = "delete from user_friends where user_id=#{user} and friend_id=#{friend}"
    ActiveRecord::Base.connection.execute(sql)
  end
  
  def self.add_friend(user,friend)
    
    user_friend = UserFriends.new
    
    user_friend.user_id = user
    user_friend.friend_id = friend
    
    user_friend.fan_since = Time.now
    user_friend.friend_since = Time.now
    
    
    user_friend.is_fan = 0
    user_friend.save()
    
    
  end
  
  def self.reject_friendship_to_fan(user, friend)
    sql = "delete from user_friends where user_id=#{user} and friend_id=#{friend}"
    ActiveRecord::Base.connection.execute(sql)
  end
  def self.promote_fan_to_friend(user, friend)
    sql = "update user_friends set is_fan = 0, friend_since = now() where user_id=#{user} and friend_id=#{friend}"
    
    ActiveRecord::Base.connection.execute(sql)
  end
  
  def self.create_fan(user, friend)
    
    
    user_friend = UserFriends.new
    user_friend.user_id = user
    
    user_friend.friend_id = friend
    user_friend.fan_since = Time.now
    
    user_friend.is_fan = 1
    user_friend.save()
  end
end
