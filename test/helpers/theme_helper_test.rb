require "test_helper"

class ThemeHelperTest < ActionView::TestCase
  test "chooses the higher contrast black or white foreground" do
    assert_equal "#FFFFFF", readable_text_color("#1D4ED8")
    assert_equal "#000000", readable_text_color("#FF0000")
    assert_equal "#000000", readable_text_color("#F8FAFC")
  end
end
