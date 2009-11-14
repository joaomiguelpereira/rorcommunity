require File.dirname(__FILE__) + '/../test_helper'
require 'openidsession_controller'

# Re-raise errors caught by the controller.
class OpenidsessionController; def rescue_action(e) raise e end; end

class OpenidsessionControllerTest < Test::Unit::TestCase
  def setup
    @controller = OpenidsessionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
