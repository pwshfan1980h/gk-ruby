require "test_helper"
require "stringio"

class RequestSizeLimiterTest < ActiveSupport::TestCase
  test "rejects a declared body larger than the application limit" do
    called = false
    app = ->(_env) { called = true; [ 200, {}, [ "ok" ] ] }
    status, headers, body = RequestSizeLimiter.new(app).call(
      "CONTENT_LENGTH" => (RequestSizeLimiter::MAX_BYTES + 1).to_s
    )

    assert_equal 413, status
    assert_equal "text/plain; charset=utf-8", headers.fetch("content-type")
    assert_equal "Request body is too large.\n", body.join
    assert_not called
  end

  test "rejects an oversized streamed body without a content length" do
    body = StringIO.new("x" * (RequestSizeLimiter::MAX_BYTES + 1))
    app = lambda do |env|
      env.fetch("rack.input").read
      [ 200, {}, [ "ok" ] ]
    end

    status, _headers, response_body = RequestSizeLimiter.new(app).call("rack.input" => body)

    assert_equal 413, status
    assert_equal "Request body is too large.\n", response_body.join
  end
end
