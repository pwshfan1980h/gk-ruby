class PrivacyDigest
  def self.call(value, purpose:)
    return if value.blank?

    key = Rails.application.key_generator.generate_key(
      "gk-ruby/#{purpose}/#{Date.current.iso8601}", 32
    )
    OpenSSL::HMAC.hexdigest("SHA256", key, value.to_s)
  end
end
