require File.dirname(__FILE__) + '/../test_helper'
require 'user_notification_controller'

# Re-raise errors caught by the controller.
class UserNotificationController; def rescue_action(e) raise e end; end

class UserNotificationControllerTest < Test::Unit::TestCase
  def setup
    @controller = UserNotificationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
