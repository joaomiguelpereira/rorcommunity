require File.dirname(__FILE__) + '/../test_helper'
require 'header_controller'

# Re-raise errors caught by the controller.
class HeaderController; def rescue_action(e) raise e end; end

class HeaderControllerTest < Test::Unit::TestCase
  def setup
    @controller = HeaderController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
