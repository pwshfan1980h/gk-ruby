require "test_helper"

class SubmissionRetentionJobTest < ActiveJob::TestCase
  test "deletes expired contents but retains a content-free audit event" do
    submission = submissions(:one)
    submission.update_column(:retained_until, 1.minute.ago)

    assert_difference -> { Submission.count }, -1 do
      assert_difference -> { AuditEvent.where(action: "submission.retention_deleted").count }, 1 do
        SubmissionRetentionJob.perform_now
      end
    end

    event = AuditEvent.where(action: "submission.retention_deleted").last
    assert_equal submission.reference_number, event.metadata.fetch("reference_number")
    assert_not_includes event.metadata.to_json, "A fixture complaint"
  end
end
