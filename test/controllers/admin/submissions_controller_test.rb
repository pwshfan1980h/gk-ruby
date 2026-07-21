require "test_helper"

class Admin::SubmissionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "lists only the current organization's submissions" do
    get admin_organization_submissions_path(organizations(:acme))

    assert_response :success
    assert_select "td", text: submissions(:one).reference_number
    assert_select "td", text: submissions(:two).reference_number, count: 0
  end

  test "cannot read a submission from another organization through an id" do
    get admin_organization_submission_path(organizations(:acme), submissions(:two))

    assert_response :not_found
  end

  test "cannot select an organization without a membership" do
    get admin_organization_path(organizations(:beta))

    assert_response :not_found
  end

  test "updates status and writes an audit event" do
    assert_difference -> { AuditEvent.where(action: "submission.status_changed").count }, 1 do
      patch admin_organization_submission_path(organizations(:acme), submissions(:one)),
        params: { submission: { status: "in_review" } }
    end

    assert_redirected_to admin_organization_submission_path(organizations(:acme), submissions(:one))
    assert_predicate submissions(:one).reload, :in_review?
  end

  test "CSV export neutralizes spreadsheet formulas" do
    submissions(:one).update!(answers: { "incident-summary" => "=HYPERLINK(\"https://example.invalid\")" })

    get export_admin_organization_submissions_path(organizations(:acme))

    assert_response :success
    assert_equal "text/csv; charset=utf-8", response.headers["Content-Type"]
    assert_includes response.body, %q('=HYPERLINK)
    assert_not_includes response.body, submissions(:two).reference_number
  end
end
