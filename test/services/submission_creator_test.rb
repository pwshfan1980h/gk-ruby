require "test_helper"

class SubmissionCreatorTest < ActiveSupport::TestCase
  Request = Data.define(:remote_ip, :user_agent)

  setup do
    @organization = organizations(:acme)
    @organization.update!(monthly_submission_limit: 1)
    @request = Request.new(remote_ip: "192.0.2.25", user_agent: "Test browser")
  end

  test "rejects an accepted submission beyond the rolling organization limit" do
    assert_no_difference -> { @organization.submissions.count } do
      assert_raises SubmissionCreator::LimitReached do
        create_submission
      end
    end
  end

  test "does not count submissions older than thirty days" do
    submissions(:one).update_column(:submitted_at, 31.days.ago)

    assert_difference -> { @organization.submissions.count }, 1 do
      assert_predicate create_submission, :persisted?
    end
  end

  private
    def create_submission
      SubmissionCreator.new(
        organization: @organization,
        form_version: form_versions(:one),
        answers: { "incident-summary" => "A complaint within the service limit." },
        request: @request
      ).call
    end
end
