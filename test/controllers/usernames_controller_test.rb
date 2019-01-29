require 'test_helper'

class UsernamesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get usernames_index_url
    assert_response :success
  end

end
