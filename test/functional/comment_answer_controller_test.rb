require File.dirname(__FILE__) + '/../test_helper'
require 'comment_answer_controller'

# Re-raise errors caught by the controller.
class CommentAnswerController; def rescue_action(e) raise e end; end

class CommentAnswerControllerTest < Test::Unit::TestCase
  def setup
    @controller = CommentAnswerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
