class RequestSizeLimiter
  MAX_BYTES = 12 * 1024 * 1024
  class PayloadTooLarge < StandardError; end

  class LimitedInput
    def initialize(input)
      @input = input
      @bytes_read = 0
    end

    def read(length = nil, outbuf = nil)
      remaining_with_sentinel = MAX_BYTES - @bytes_read + 1
      requested = length ? [ length, remaining_with_sentinel ].min : remaining_with_sentinel
      data = @input.read(requested)
      count!(data)
      return data unless outbuf

      outbuf.replace(data.to_s)
    end

    def gets(*args)
      data = @input.gets(*args)
      count!(data)
      data
    end

    def each
      return enum_for(:each) unless block_given?

      while (line = gets)
        yield line
      end
    end

    def rewind
      @bytes_read = 0
      @input.rewind
    end

    def method_missing(method_name, ...)
      @input.public_send(method_name, ...)
    end

    def respond_to_missing?(method_name, include_private = false)
      @input.respond_to?(method_name, include_private) || super
    end

    private
      def count!(data)
        @bytes_read += data.to_s.bytesize
        raise PayloadTooLarge if @bytes_read > MAX_BYTES
      end
  end

  def initialize(app)
    @app = app
  end

  def call(env)
    content_length = env["CONTENT_LENGTH"].to_i
    return payload_too_large if content_length > MAX_BYTES

    env["rack.input"] = LimitedInput.new(env["rack.input"]) if env["rack.input"]
    @app.call(env)
  rescue PayloadTooLarge
    payload_too_large
  end

  private
    def payload_too_large
      body = "Request body is too large.\n"
      [
        413,
        { "content-type" => "text/plain; charset=utf-8", "content-length" => body.bytesize.to_s },
        [ body ]
      ]
    end
end
