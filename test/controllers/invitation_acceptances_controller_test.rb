require "test_helper"

class InvitationAcceptancesControllerTest < ActionDispatch::IntegrationTest
  test "an invited person creates an account and receives scoped access" do
    invitation = Invitation.create!(
      organization: organizations(:acme),
      invited_by: users(:one),
      email_address: "invited@example.com"
    )
    token = invitation.generate_token_for(:acceptance)

    assert_difference [ -> { User.count }, -> { Membership.count } ], 1 do
      post invitation_acceptance_path(token: token), params: {
        user: {
          name: "Invited Admin",
          password: "Correct-Horse-Battery-3",
          password_confirmation: "Correct-Horse-Battery-3"
        }
      }
    end

    assert_redirected_to admin_organization_path(organizations(:acme))
    assert invitation.reload.accepted_at
    assert_equal organizations(:acme), User.find_by!(email_address: "invited@example.com").organizations.first
  end

  test "an invalid invitation creates no account" do
    assert_no_difference -> { User.count } do
      post invitation_acceptance_path(token: "fabricated"), params: {
        user: { name: "Intruder", password: "Correct-Horse-Battery-4" }
      }
    end

    assert_redirected_to new_session_path
  end
end
