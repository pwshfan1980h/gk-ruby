class SubmissionCreator
  class LimitReached < StandardError; end

  def initialize(organization:, form_version:, answers:, request:)
    @organization = organization
    @form_version = form_version
    @answers = answers
    @request = request
  end

  def call
    attempts = 0

    begin
      organization.with_lock do
        enforce_monthly_limit!
        Submission.create!(
          organization: organization,
          form_version: form_version,
          answers: answers,
          submitter_ip_digest: PrivacyDigest.call(request.remote_ip, purpose: "submission-ip"),
          user_agent: request.user_agent.to_s.first(500)
        )
      end
    rescue ActiveRecord::RecordNotUnique
      attempts += 1
      retry if attempts < 3
      raise
    end
  end

  private
    attr_reader :organization, :form_version, :answers, :request

    def enforce_monthly_limit!
      recent_count = organization.submissions.where("submitted_at >= ?", 30.days.ago).count
      raise LimitReached, "This form has reached its submission limit." if recent_count >= organization.monthly_submission_limit
    end
end
