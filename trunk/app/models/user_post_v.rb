class UserPostV < ActiveRecord::Base
  set_table_name "user_posts_v"
  #set_table_name "posts"
  attr_accessor :vote
   
  def user
    User.find(self.user_id)
  end
  
  
  #def rank
  #  sql = "select ((count_comments(#{self.id})*3) + (count_votes(#{self.id})*4) + (count_saved_by(#{self.id})*5) /12)"

   # result = ActiveRecord::Base.connection.select_one(sql)

    #sql = "select label_count, post_id, label_id from original_post_labels where post_id=#{post_id}"
    #result = ActiveRecord::Base.connection.select_all(sql)
    #ret = Array.new
    #result.each do |temp|
    #  ret <<   Label.find(temp["label_id"]).name
    #end
   # ret

  
  #end
  

  def voted(user_id)
    user_vote = UserVote.find_vote(user_id, self.id)
    if ( user_vote )
      self.vote = user_vote.vote 
      return true
    else
      self.vote = 0
      return false
    end
  end
  
end
