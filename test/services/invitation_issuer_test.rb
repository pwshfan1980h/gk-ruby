require "test_helper"

class InvitationIssuerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "issues a seven-day invitation for the second administrator seat" do
    invitation = nil
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      invitation = InvitationIssuer.new(
        organization: organizations(:acme),
        invited_by: users(:one),
        email_address: " second@example.com "
      ).call
    end

    assert_equal "second@example.com", invitation.email_address
    assert_in_delta 7.days.from_now, invitation.expires_at, 2.seconds
  end

  test "does not issue more than two administrator seats" do
    organizations(:acme).memberships.create!(user: users(:two), role: :administrator)

    error = assert_raises(ActiveRecord::RecordInvalid) do
      InvitationIssuer.new(
        organization: organizations(:acme),
        invited_by: users(:one),
        email_address: "third@example.com"
      ).call
    end

    assert_includes error.record.errors[:base], "This organization already uses both administrator seats"
  end
end
