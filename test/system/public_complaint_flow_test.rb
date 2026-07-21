require "application_system_test_case"

class PublicComplaintFlowTest < ApplicationSystemTestCase
  test "a visitor submits the published complaint form" do
    visit public_form_path(organization_slug: organizations(:acme).slug)

    assert_text "Tell us what happened"
    assert_accessible
    fill_in "What happened?", with: "The published complaint form worked end to end."
    attach_file "Supporting document", Rails.root.join("test/fixtures/files/supporting-note.txt")
    sleep 1.1

    assert_difference -> { organizations(:acme).submissions.count }, 1 do
      click_button "Submit complaint"
      assert_text "Complaint received"
    end

    assert_text(/GK-[A-F0-9]{12}/)
    metadata = organizations(:acme).submissions.order(:created_at).last.answers.fetch("supporting-document")
    assert_equal "supporting-note.txt", metadata.fetch("filename")
    assert_not metadata.key?("contents")
  end

  test "an administrator uses a preset without publishing the draft" do
    visit new_session_path
    fill_in "Email address", with: users(:one).email_address
    fill_in "Password", with: "Correct-Horse-Battery-1"
    click_button "Sign in"

    click_link organizations(:acme).name
    click_link "Edit draft"
    assert_text "Edit complaint form"
    assert_accessible

    find("button[aria-label='Use teal accent']").click
    assert_field "Accent color", with: "#047857"
    click_button "Save draft"

    assert_text "Draft saved. The public form has not changed."
    assert_equal "#047857", organizations(:acme).reload.accent_color
    assert_predicate form_versions(:one).reload, :published?
  end
end
