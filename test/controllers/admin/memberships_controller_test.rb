require "test_helper"

class Admin::MembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @second_membership = organizations(:acme).memberships.create!(
      user: users(:two), role: :administrator
    )
    sign_in_as(users(:one))
  end

  test "an owner can deactivate another administrator" do
    assert_difference -> { AuditEvent.where(action: "administrator.deactivated").count }, 1 do
      delete admin_organization_membership_path(organizations(:acme), @second_membership)
    end

    assert_redirected_to admin_organization_path(organizations(:acme))
    assert_not @second_membership.reload.active?
  end

  test "an owner cannot deactivate their own access" do
    own_membership = memberships(:acme_owner)

    delete admin_organization_membership_path(organizations(:acme), own_membership)

    assert_redirected_to admin_organization_path(organizations(:acme))
    assert own_membership.reload.active?
  end

  test "a membership id from another tenant is not found" do
    delete admin_organization_membership_path(organizations(:acme), memberships(:beta_owner))

    assert_response :not_found
  end
end
