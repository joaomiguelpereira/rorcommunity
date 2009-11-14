require File.dirname(__FILE__) + '/../test_helper'
require 'user_image_controller'

# Re-raise errors caught by the controller.
class UserImageController; def rescue_action(e) raise e end; end

class UserImageControllerTest < Test::Unit::TestCase
  def setup
    @controller = UserImageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
