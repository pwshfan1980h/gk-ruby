require "test_helper"

class Admin::FormsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "renders the organization-scoped draft editor" do
    get edit_admin_organization_form_path(organizations(:acme))

    assert_response :success
    assert_select "h1", "Edit complaint form"
    assert_select "input[name='form_version[lock_version]']"
    assert_select "#organization_accent_color", count: 1
    assert_select "#organization_accent_color_picker[aria-label='Accent color picker']", count: 1
    assert_select "button[data-action='theme-color#usePreset']", count: 5
  end

  test "does not expose another organization's editor" do
    get edit_admin_organization_form_path(organizations(:beta))

    assert_response :not_found
  end

  test "publishes the saved draft and immediately creates another draft" do
    published_version = form_versions(:acme_draft)

    patch publish_admin_organization_form_path(organizations(:acme))

    assert_redirected_to edit_admin_organization_form_path(organizations(:acme))
    assert_predicate published_version.reload, :published?
    assert_equal 1, forms(:one).versions.published.count
    assert_equal 1, forms(:one).versions.draft.count
  end

  test "saves theme and draft field changes without changing the public version" do
    draft = form_versions(:acme_draft)
    field = form_fields(:acme_draft_summary)
    public_title = form_versions(:one).title

    patch admin_organization_form_path(organizations(:acme)), params: {
      organization: {
        name: "Acme Support",
        accent_color: "#7C3AED",
        privacy_notice: "A revised privacy notice.",
        retention_days: 60
      },
      form_version: {
        title: "A revised private draft",
        intro: draft.intro,
        confirmation_message: draft.confirmation_message,
        lock_version: draft.lock_version,
        fields_attributes: {
          "0" => {
            id: field.id,
            label: "Describe the problem",
            field_type: "long_text",
            required: "1",
            position: 0,
            max_length: 4_000,
            options_text: ""
          }
        }
      }
    }

    assert_redirected_to edit_admin_organization_form_path(organizations(:acme))
    assert_equal "#7C3AED", organizations(:acme).reload.accent_color
    assert_equal "A revised private draft", draft.reload.title
    assert_equal "Describe the problem", field.reload.label
    assert_equal public_title, form_versions(:one).reload.title
  end

  test "rejects a stale draft edit instead of overwriting it" do
    draft = form_versions(:acme_draft)

    patch admin_organization_form_path(organizations(:acme)), params: {
      organization: { name: organizations(:acme).name },
      form_version: {
        title: "Stale title",
        intro: draft.intro,
        confirmation_message: draft.confirmation_message,
        lock_version: draft.lock_version - 1
      }
    }

    assert_response :conflict
    assert_select "[role='status']", text: /Another administrator saved/
    assert_not_equal "Stale title", draft.reload.title
  end

  test "draft preview cannot submit" do
    assert_difference -> { AuditEvent.where(action: "form.draft_previewed").count }, 1 do
      get preview_admin_organization_form_path(organizations(:acme))
    end

    assert_response :success
    assert_select "div[role='status']", text: /Draft preview/
    assert_select "button[disabled]", text: /Submission disabled/
    assert_select "input[name='form_token']", count: 0
  end
end
