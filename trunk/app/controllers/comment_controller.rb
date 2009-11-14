class CommentController < BaseController
  
  
  
  def agree_with_comment
    @comment_id = params[:id]
    user_id = session[:logged_user]
    @logged = true
    @votes = 0
    if user_id.nil?
      @logged = false
    else
      if @comment_id.nil?
        return
      end
      
      comment = Comment.find(@comment_id, :lock=>true)
      Comment.transaction do
        comment.votes +=1
        comment.update
        @votes = comment.votes 
      end
      
      #do also the track
      comment_vote = CommentVote.new(:comment_id=>@comment_id,:user_id=>user_id,:vote=>1)
      comment_vote.save()
      
      
    end
  end  
  
  def disagree_with_comment
    @comment_id = params[:id]
    user_id = session[:logged_user]
    @logged = true
    @votes = 0
    if user_id.nil?
      @logged = false
    else
      if @comment_id.nil?
        return
      end
      comment = Comment.find(@comment_id, :lock=>true)
      Comment.transaction do
        comment.votes +=-1
        comment.update
        @votes = comment.votes 
      end
      #do also the track
      comment_vote = CommentVote.new(:comment_id=>@comment_id,:user_id=>user_id,:vote=>-1)
      comment_vote.save()
    end
  end  
  
  def show_new_comment_area
    post_id = params[:id]
    @logged = true
    if post_id.nil?
      return
    end
    if session[:logged_user].nil?
      @logged =false
    else
      
      logged_user = User.find(session[:logged_user])
      @newCommentInfo = NewCommentInfo.new()
      @newCommentInfo.logged_user =logged_user
      
      @newCommentInfo.post_id = post_id
    end
  end
  
  def hide_new_comment_area
    
    @post_id = params[:id]
    @logged = true
    if @post_id.nil?
      return
    end
    if session[:logged_user].nil?
      @logged =false
    else
      #does nothing
    end
  end
  
  
  
  def save_new_comment
    
    @post_id = params[:id]
    @logged = true
    @saved = true
    @comment_id = nil
    logged_user = session[:logged_user]
    
    if @post_id.nil?
      return
    end
    
    @comment = params[:comment] 
    
    #by br
    tmp_comment = @comment.strip()
    @number_of_comments = 0
    
    if logged_user.nil?
      @logged =false
    else
      if @comment.nil? || tmp_comment.size() == 0 
        @saved = false  
      else
        #@comment = @comment.gsub(/\n/, '<br />')
        post = Post.find(@post_id)
        user = User.find(logged_user)
        @post_comment = Comment.new
        @post_comment.votes = 0
        @post_comment.comment = @comment
        @post_comment.user_id = logged_user
        post.comments << @post_comment 
        @number_of_comments = post.comments.count
        #
        #new_comment.post_id = @post_id
        # unless new_comment.save()
        #   @saved = false 
        # end
      end
      #does nothing
    end
    
  end
end
