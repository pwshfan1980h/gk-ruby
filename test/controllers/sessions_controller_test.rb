require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
    @user = User.take
  end

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: {
      email_address: @user.email_address,
      password: "Correct-Horse-Battery-1"
    }

    assert_redirected_to admin_root_path
    assert cookies[:session_id]
    assert_not_equal "127.0.0.1", @user.sessions.order(:created_at).last.ip_digest
    assert_nil @user.sessions.order(:created_at).last.attributes["ip_address"]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as(User.take)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end

  test "an expired session cannot authenticate" do
    expired_session = @user.sessions.create!
    expired_session.update_column(:expires_at, 1.minute.ago)
    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = expired_session.id
      cookies["session_id"] = cookie_jar[:session_id]
    end

    get admin_root_path

    assert_redirected_to new_session_path
    assert_not Session.exists?(expired_session.id)
  end

  test "throttles repeated sign-in attempts" do
    10.times do
      post session_path, params: { email_address: @user.email_address, password: "wrong" }
      assert_redirected_to new_session_path
    end

    post session_path, params: {
      email_address: @user.email_address,
      password: "Correct-Horse-Battery-1"
    }
    assert_redirected_to new_session_path
    follow_redirect!
    assert_select "div", /Try again later/
  end
end
