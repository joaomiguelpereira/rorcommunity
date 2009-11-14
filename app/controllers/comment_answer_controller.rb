class CommentAnswerController < ApplicationController
  
  
  def disagree_with_answer
    @answer_id = params[:id]
    user_id = session[:logged_user]
    @logged = true
    @votes = 0
    if user_id.nil?
      @logged = false
    else
      if @answer_id.nil?
        return
      end
      
      comment_answer = CommentAnswer.find(@answer_id, :lock=>true)
      CommentAnswer.transaction do
        comment_answer.votes +=-1
        comment_answer.update
        @votes = comment_answer.votes 
      end
      
      #do also the track
      answer_vote = AnswerVote.new(:answer_id=>@answer_id,:user_id=>user_id,:vote=>-1)
      answer_vote.save()
    end
  
  end
  
  def agree_with_answer
    @answer_id = params[:id]
    user_id = session[:logged_user]
    @logged = true
    @votes = 0
    if user_id.nil?
      @logged = false
    else
      if @answer_id.nil?
        return
      end
      
      comment_answer = CommentAnswer.find(@answer_id, :lock=>true)
      CommentAnswer.transaction do
        comment_answer.votes +=1
        comment_answer.update
        @votes = comment_answer.votes 
      end
      
      #do also the track
      answer_vote = AnswerVote.new(:answer_id=>@answer_id,:user_id=>user_id,:vote=>1)
      answer_vote.save()
    end
  end

  def show_answer_area
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
      logged_user = User.find(session[:logged_user])
      @newCommentInfo = NewCommentInfo.new()
      @newCommentInfo.logged_user =logged_user
      @newCommentInfo.post_id = @comment_id
    end
  end
  def hide_new_answer_area
    @logged = true
    user_id = session[:logged_user]
    @comment_id = params[:id]
    if user_id.nil?
      @logged = false
    end
  end
  
  def save_new_comment_answer
    
    @comment_id = params[:id]
    logged_user = session[:logged_user]
    @answer_text = params[:answer]
    tmp_answer = @answer_text.strip()
    @number_of_answers = 0
    @saved = true 
    @logged = true
    if logged_user.nil?
      @logged = false
    else
      if @answer_text.nil? || tmp_answer.size() == 0 
        @saved = false  
      else
        comment = Comment.find(@comment_id)
        user = User.find(logged_user)
        @comment_answer= CommentAnswer.new
        @comment_answer.votes = 0
        @comment_answer.answer = @answer_text
        @comment_answer.user_id = logged_user
        comment.comment_answers << @comment_answer 
        @number_of_answers = comment.comment_answers.count
      end
      
    end
  end
end
