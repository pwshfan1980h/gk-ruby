require "test_helper"

class FormVersionTest < ActiveSupport::TestCase
  test "published content is immutable" do
    version = form_versions(:one)

    assert_not version.update(title: "A changed public title")
    assert_includes version.errors[:base], "published form content cannot be changed"
  end

  test "draft content can be edited" do
    version = form_versions(:acme_draft)

    assert version.update(title: "A clearer title")
  end
end
