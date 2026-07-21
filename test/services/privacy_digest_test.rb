require "test_helper"

class PrivacyDigestTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  test "is stable within a day and unlinkable across days" do
    travel_to Time.zone.local(2026, 7, 20, 12)
    first = PrivacyDigest.call("192.0.2.10", purpose: "test-ip")
    assert_equal first, PrivacyDigest.call("192.0.2.10", purpose: "test-ip")
    assert_not_includes first, "192.0.2.10"

    travel 1.day
    assert_not_equal first, PrivacyDigest.call("192.0.2.10", purpose: "test-ip")
  end
end
