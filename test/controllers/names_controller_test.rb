require 'test_helper'

class NamesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get names_index_url
    assert_response :success
  end

  test "should get create" do
    get names_create_url
    assert_response :success
  end

end
