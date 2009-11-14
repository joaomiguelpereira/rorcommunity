require File.dirname(__FILE__) + '/../test_helper'
require 'tag_cloud_controller'

# Re-raise errors caught by the controller.
class TagCloudController; def rescue_action(e) raise e end; end

class TagCloudControllerTest < Test::Unit::TestCase
  def setup
    @controller = TagCloudController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
