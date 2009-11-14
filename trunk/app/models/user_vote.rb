class UserVote < ActiveRecord::Base
  
  before_save :do_before_save
  
  def user
    User.find(self.user_id)
  end
  
  def post
    #Post.find(self.post_id)
    UserPostV.find(self.post_id)
  end
  
  
  
 
  
  def self.count_votes_for_user(user_id)
    UserVote.count_by_sql("select count(*) from user_votes where user_id=#{user_id}")
  end
  
  def self.clear_post_votes(post_id) 
    sql = "delete from user_votes where post_id=#{post_id}"
    ActiveRecord::Base.connection.execute(sql)
  end
  
  def self.remove_user_vote(user_id, post_id)
    sql = "delete from user_votes where user_id=#{user_id} and post_id=#{post_id}"
    ActiveRecord::Base.connection.execute(sql)    
  end
  
  def self.update_post_votes(old_id, new_id)
    sql = "update user_votes set post_id=#{new_id} where post_id=#{old_id}"
    ActiveRecord::Base.connection.execute(sql)
  end
  
  def self.find_vote(user_id, post_id)
    vote = nil
    votes = UserVote.find_by_sql("select * from user_votes where user_id=#{user_id} and post_id=#{post_id}");
    
    if votes.size > 0
      vote = votes[0]
      
    end  
    
    vote
  end
  
  def do_before_save
    if self.vote.nil?
      self.vote = 1
    end
    self.voted_at = Time.now
  end
  
  
  
  
end
