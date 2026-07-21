require "test_helper"

class FormFieldTest < ActiveSupport::TestCase
  test "choice fields require bounded choices" do
    field = FormField.new(
      form_version: form_versions(:acme_draft),
      field_type: :select,
      label: "Topic",
      position: 1,
      options: []
    )

    assert_not field.valid?
    assert_includes field.errors[:options], "must contain between 1 and 20 choices"
  end

  test "published fields cannot be edited" do
    field = form_fields(:one)

    assert_not field.update(label: "Changed")
    assert_includes field.errors[:form_version], "is published and cannot be changed"
  end
end
