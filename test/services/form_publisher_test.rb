require "test_helper"

class FormPublisherTest < ActiveSupport::TestCase
  test "atomically replaces the public version and creates a new draft" do
    form = forms(:one)
    old_publication = form_versions(:one)
    draft = form_versions(:acme_draft)

    result = FormPublisher.new(form: form, actor: users(:one)).call

    assert_predicate old_publication.reload, :archived?
    assert_predicate draft.reload, :published?
    assert_equal draft, result.published_version
    assert_predicate result.draft_version, :draft?
    assert_equal 3, result.draft_version.version_number
    assert_equal draft.fields.pluck(:field_key), result.draft_version.fields.pluck(:field_key)
    assert_equal 1, form.versions.published.count
    assert_equal 1, form.versions.draft.count
    assert_equal "form.published", AuditEvent.order(:created_at).last.action
  end

  test "a different organization is not affected" do
    beta_publication = form_versions(:two)

    FormPublisher.new(form: forms(:one), actor: users(:one)).call

    assert_predicate beta_publication.reload, :published?
  end
end
