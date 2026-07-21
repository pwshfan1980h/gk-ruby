class Submission < ApplicationRecord
  MAX_ANSWER_BYTES = 50.kilobytes
  MAX_SIMULATED_FILE_BYTES = 10.megabytes
  SIMULATED_FILE_EXTENSIONS = %w[.pdf .jpg .jpeg .png .docx .txt].freeze

  belongs_to :organization
  belongs_to :form_version

  enum :status, { new_submission: 0, in_review: 1, resolved: 2 },
    default: :new_submission

  before_validation :assign_reference_number, on: :create
  before_validation :set_lifecycle_dates, on: :create

  validates :reference_number, presence: true, uniqueness: true
  validates :status, presence: true
  validates :answers, presence: true
  validates :submitted_at, :retained_until, presence: true
  validates :user_agent, length: { maximum: 500 }, allow_blank: true
  validate :organization_matches_version
  validate :answers_match_form

  private
    def assign_reference_number
      self.reference_number ||= "GK-#{SecureRandom.hex(6).upcase}"
    end

    def set_lifecycle_dates
      self.submitted_at ||= Time.current
      self.retained_until ||= submitted_at + organization.retention_days.days if organization
    end

    def organization_matches_version
      return if form_version.nil? || organization_id == form_version.organization_id

      errors.add(:organization, "must own the form version")
    end

    def answers_match_form
      return unless answers.is_a?(Hash) && form_version

      if answers.to_json.bytesize > MAX_ANSWER_BYTES
        errors.add(:answers, "are too large")
        return
      end

      fields_by_key = form_version.fields.index_by(&:field_key)
      unknown_keys = answers.keys.map(&:to_s) - fields_by_key.keys
      errors.add(:answers, "contain unsupported fields") if unknown_keys.any?

      fields_by_key.each_value do |field|
        validate_answer(field, answers[field.field_key])
      end
    end

    def validate_answer(field, value)
      if answer_blank?(value)
        errors.add(answer_attribute(field), "is required") if field.required?
        return
      end

      case field.field_type
      when "short_text", "long_text"
        validate_text_answer(field, value)
      when "email"
        add_answer_error(field, "is not a valid email address") unless value.to_s.match?(URI::MailTo::EMAIL_REGEXP) && value.to_s.length <= 320
      when "phone"
        add_answer_error(field, "is not a valid telephone number") unless value.to_s.match?(/\A[0-9+().\-\s]{7,30}\z/)
      when "date"
        validate_date_answer(field, value)
      when "select", "radio"
        add_answer_error(field, "is not one of the available choices") unless value.in?(field.options)
      when "checkbox"
        add_answer_error(field, "must be accepted") unless ActiveModel::Type::Boolean.new.cast(value)
      when "simulated_file"
        validate_simulated_file(field, value)
      end
    end

    def validate_text_answer(field, value)
      add_answer_error(field, "is too long (maximum is #{field.response_max_length} characters)") if value.to_s.length > field.response_max_length
    end

    def validate_date_answer(field, value)
      parsed = Date.iso8601(value.to_s)
      add_answer_error(field, "must be between 1900 and today") unless parsed.between?(Date.new(1900, 1, 1), Date.current)
    rescue Date::Error
      add_answer_error(field, "is not a valid date")
    end

    def validate_simulated_file(field, value)
      unless value.is_a?(Hash) && value["simulated"] == true
        add_answer_error(field, "is not a valid simulated attachment")
        return
      end

      filename = value["filename"].to_s
      byte_size = value["byte_size"].to_i
      extension = File.extname(filename).downcase
      add_answer_error(field, "has an unsupported file type") unless extension.in?(SIMULATED_FILE_EXTENSIONS)
      add_answer_error(field, "is larger than 10 MB") unless byte_size.between?(1, MAX_SIMULATED_FILE_BYTES)
      add_answer_error(field, "has an invalid filename") if filename.blank? || filename.length > 255
    end

    def answer_blank?(value)
      value.blank? || (value.is_a?(Hash) && value.values.all?(&:blank?))
    end

    def answer_attribute(field)
      :"answer_#{field.field_key}"
    end

    def add_answer_error(field, message)
      errors.add(answer_attribute(field), message)
    end
end
