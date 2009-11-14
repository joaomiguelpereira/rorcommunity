class CommentVote < ActiveRecord::Base
  before_save :add_date
  
  
  def self.count_comments_votes_for_user(user_id)
    CommentVote.count_by_sql("select count(*) from comment_votes where user_id=#{user_id}")
  end
  
  
  private
  def add_date
    self.voted_at = Time.now
  end
end
