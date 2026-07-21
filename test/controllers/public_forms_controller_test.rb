require "test_helper"

class PublicFormsControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  setup { Rails.cache.clear }

  test "shows the organization's published form without authentication" do
    get public_form_path(organization_slug: organizations(:acme).slug)

    assert_response :success
    assert_select "h1", form_versions(:one).title
    assert_select "label", text: /What happened\?/
    assert_select "p", text: /file's name, type, and size are recorded/
    assert_includes response.headers.fetch("Content-Security-Policy"), "frame-ancestors 'none'"
    assert_select "style[nonce]", count: 1
  end

  test "accepts a valid complaint and returns a stable reference" do
    get public_form_path(organization_slug: organizations(:acme).slug)
    token = css_select("input[name='form_token']").first["value"]

    assert_difference -> { organizations(:acme).submissions.count }, 1 do
      travel 2.seconds do
        post public_form_path(organization_slug: organizations(:acme).slug), params: {
          form_token: token,
          submission: { answers: { "incident-summary" => "A clear account of what happened." } }
        }
      end
    end

    submission = organizations(:acme).submissions.order(:created_at).last
    assert_redirected_to public_form_confirmation_path(
      organization_slug: organizations(:acme).slug,
      reference_number: submission.reference_number
    )
    assert_match(/\AGK-[A-F0-9]{12}\z/, submission.reference_number)
  end

  test "retains only simulated attachment metadata" do
    get public_form_path(organization_slug: organizations(:acme).slug)
    token = css_select("input[name='form_token']").first["value"]
    upload = fixture_file_upload("supporting-note.txt", "text/plain")

    travel 2.seconds do
      post public_form_path(organization_slug: organizations(:acme).slug), params: {
        form_token: token,
        submission: {
          answers: {
            "incident-summary" => "Details with supporting metadata.",
            "supporting-document" => upload
          }
        }
      }
    end

    metadata = organizations(:acme).submissions.order(:created_at).last.answers.fetch("supporting-document")
    assert_equal "supporting-note.txt", metadata.fetch("filename")
    assert_equal "text/plain", metadata.fetch("content_type")
    assert_equal true, metadata.fetch("simulated")
    assert_not metadata.key?("contents")
  end

  test "rejects a missing required answer without creating a submission" do
    get public_form_path(organization_slug: organizations(:acme).slug)
    token = css_select("input[name='form_token']").first["value"]

    assert_no_difference -> { Submission.count } do
      travel 2.seconds do
        post public_form_path(organization_slug: organizations(:acme).slug), params: {
          form_token: token, submission: { answers: {} }
        }
      end
    end

    assert_response :unprocessable_content
    assert_select "[role='alert']", text: /Please correct/
  end

  test "an expired or fabricated form token creates nothing" do
    assert_no_difference -> { Submission.count } do
      post public_form_path(organization_slug: organizations(:acme).slug), params: {
        form_token: "not-a-token",
        submission: { answers: { "incident-summary" => "Should not persist." } }
      }
    end

    assert_redirected_to public_form_path(organization_slug: organizations(:acme).slug)
  end

  test "a confirmation reference must belong to the organization" do
    get public_form_confirmation_path(
      organization_slug: organizations(:acme).slug,
      reference_number: submissions(:two).reference_number
    )

    assert_response :not_found
  end

  test "throttles excessive submissions by organization and privacy-safe IP key" do
    get public_form_path(organization_slug: organizations(:acme).slug)
    token = css_select("input[name='form_token']").first["value"]
    path = public_form_path(organization_slug: organizations(:acme).slug)
    params = {
      form_token: token,
      submission: { answers: { "incident-summary" => "A rate-limit test complaint." } }
    }

    travel 2.seconds do
      assert_difference -> { organizations(:acme).submissions.count }, 30 do
        30.times do
          post path, params: params
          assert_response :see_other
        end
      end

      assert_no_difference -> { Submission.count } do
        post path, params: params
      end
      assert_response :too_many_requests
      assert_equal "Please wait before submitting again.", response.body
    end
  end
end
