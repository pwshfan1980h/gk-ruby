require "test_helper"

class OrganizationProvisionerTest < ActiveSupport::TestCase
  test "creates an owner, one public version, and one editable draft" do
    organization = OrganizationProvisioner.new(
      organization_name: "New Community Service",
      organization_slug: "new-community-service",
      admin_name: "New Owner",
      admin_email: "new-owner@example.com",
      admin_password: "Correct-Horse-Battery-2"
    ).call

    assert_equal 1, organization.memberships.owner.active.count
    assert_equal 1, organization.form.versions.published.count
    assert_equal 1, organization.form.versions.draft.count
    assert_equal OrganizationProvisioner::DEFAULT_FIELDS.size,
      organization.form.published_version.fields.count
    assert_equal organization.form.published_version.fields.pluck(:field_key),
      organization.form.draft_version.fields.pluck(:field_key)
  end

  test "rolls back every record when provisioning is invalid" do
    assert_no_difference [ -> { Organization.count }, -> { User.count }, -> { Form.count } ] do
      assert_raises(ActiveRecord::RecordInvalid) do
        OrganizationProvisioner.new(
          organization_name: "Broken",
          organization_slug: "broken",
          admin_name: "Owner",
          admin_email: "not-an-email",
          admin_password: "short"
        ).call
      end
    end
  end
end
