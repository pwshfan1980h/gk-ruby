require "test_helper"

class ReadinessControllerTest < ActionDispatch::IntegrationTest
  test "reports ready when PostgreSQL is reachable" do
    get readiness_check_path

    assert_response :success
    assert_empty response.body
  end
end
