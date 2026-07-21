require "test_helper"

class SubmissionTest < ActiveSupport::TestCase
  test "sets a reference and retention date" do
    organization = organizations(:acme)
    submission = Submission.new(
      organization: organization,
      form_version: form_versions(:one),
      answers: { "incident-summary" => "Something happened." }
    )

    assert submission.valid?
    assert_match(/\AGK-[A-F0-9]{12}\z/, submission.reference_number)
    assert_in_delta 90.days.from_now, submission.retained_until, 2.seconds
  end

  test "rejects a form version from another organization" do
    submission = Submission.new(
      organization: organizations(:acme),
      form_version: form_versions(:two),
      answers: { "beta-summary" => "Cross tenant" }
    )

    assert_not submission.valid?
    assert_includes submission.errors[:organization], "must own the form version"
  end

  test "validates answers against the immutable form version" do
    submission = Submission.new(
      organization: organizations(:acme),
      form_version: form_versions(:one),
      answers: { "incident-summary" => "" }
    )

    assert_not submission.valid?
    assert_includes submission.errors[:"answer_incident-summary"], "is required"
  end
end
