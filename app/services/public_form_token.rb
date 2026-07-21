class PublicFormToken
  PURPOSE = :public_complaint_form
  MAX_AGE = 2.hours
  Payload = Data.define(:form_version_id, :rendered_at)

  def self.generate(form_version)
    Rails.application.message_verifier(PURPOSE).generate(
      { form_version_id: form_version.id, rendered_at: Time.current.to_i },
      expires_in: MAX_AGE
    )
  end

  def self.verify!(token)
    payload = Rails.application.message_verifier(PURPOSE).verify(token)
    Payload.new(
      form_version_id: Integer(payload.fetch("form_version_id")),
      rendered_at: Time.at(Integer(payload.fetch("rendered_at")))
    )
  rescue KeyError, ArgumentError, TypeError
    raise ActiveSupport::MessageVerifier::InvalidSignature
  end
end
