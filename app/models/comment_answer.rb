class CommentAnswer < ActiveRecord::Base
  belongs_to :comment
  
 def self.count_comments_answer_on_user_links(user_id)
    CommentAnswer.count_by_sql("select count(*) from comment_answers c left join comments p on (p.id=c.comment_id) where p.user_id=#{user_id}")
  end
  
   def user_vote(user_id)
    if user_id.nil?
      return nil
    end
    answer_vote = AnswerVote.find(:first, :conditions=>["user_id=? and answer_id=?",user_id,self.id])
    answer_vote
  end
  
  def self.count_comments_answers_for_user(user_id)
    CommentAnswer.count(:conditions=>["user_id=?",user_id])
  end
  
  def user
    User.find(self.user_id)
  end
  
end
