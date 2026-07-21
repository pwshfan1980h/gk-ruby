class SubmissionRetentionJob < ApplicationJob
  queue_as :default

  def perform(batch_size = 500)
    Submission.where("retained_until <= ?", Time.current).find_each(batch_size: batch_size) do |submission|
      Submission.transaction do
        AuditRecorder.record(
          organization: submission.organization,
          action: "submission.retention_deleted",
          auditable: submission,
          metadata: { reference_number: submission.reference_number }
        )
        submission.destroy!
      end
    end
  end
end
