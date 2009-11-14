class Comment < ActiveRecord::Base
  belongs_to :post
  has_many :comment_answers
  #attr_accessor :user
  
  def self.count_comments_on_user_links(user_id)
    Comment.count_by_sql("select count(*) from comments c left join posts p on (p.id=c.post_id) where p.user_id=#{user_id}")
  end
  def user
    User.find(self.user_id)
  end
  
  def user_vote(user_id)
    if user_id.nil?
      return nil
    end
    comment_vote = CommentVote.find(:first, :conditions=>["user_id=? and comment_id=?",user_id,self.id])
    comment_vote
  end
  
  def self.count_comments_for_user(user_id)
    Comment.count(:conditions=>["user_id=?",user_id])
  end
end
