class FormField < ApplicationRecord
  FIELD_TYPES = {
    short_text: 0,
    long_text: 1,
    email: 2,
    phone: 3,
    date: 4,
    select: 5,
    radio: 6,
    checkbox: 7,
    simulated_file: 8
  }.freeze
  CHOICE_TYPES = %w[select radio].freeze
  MAX_OPTIONS = 20

  belongs_to :form_version, inverse_of: :fields

  enum :field_type, FIELD_TYPES, prefix: true

  before_validation :assign_field_key, on: :create
  before_validation :normalize_options

  validates :field_key, presence: true, uniqueness: { scope: :form_version_id }
  validates :field_type, presence: true
  validates :label, presence: true, length: { maximum: 120 }
  validates :help_text, length: { maximum: 500 }, allow_blank: true
  validates :placeholder, length: { maximum: 150 }, allow_blank: true
  validates :position, numericality: {
    only_integer: true, greater_than_or_equal_to: 0, less_than: FormVersion::MAX_FIELDS
  }
  validates :max_length, numericality: {
    only_integer: true, greater_than: 0, less_than_or_equal_to: 5_000
  }, allow_nil: true
  validate :options_match_field_type
  validate :form_version_is_editable, on: [ :create, :update ]

  before_destroy :prevent_changes_to_public_history

  def choice?
    field_type.in?(CHOICE_TYPES)
  end

  def options_text
    options.join("\n")
  end

  def options_text=(value)
    self.options = value.to_s.lines.map(&:strip).reject(&:blank?)
  end

  def response_max_length
    max_length || (field_type_long_text? ? 5_000 : 255)
  end

  private
    def assign_field_key
      self.field_key ||= SecureRandom.uuid
    end

    def normalize_options
      self.options = Array(options).filter_map do |option|
        normalized = option.to_s.strip
        normalized.presence
      end.uniq
    end

    def options_match_field_type
      if choice?
        errors.add(:options, "must contain between 1 and #{MAX_OPTIONS} choices") unless options.size.between?(1, MAX_OPTIONS)
        errors.add(:options, "cannot contain a choice longer than 80 characters") if options.any? { |option| option.length > 80 }
      elsif options.any?
        errors.add(:options, "are only supported for select and radio fields")
      end
    end

    def form_version_is_editable
      return if form_version&.editable?

      errors.add(:form_version, "is published and cannot be changed")
    end

    def prevent_changes_to_public_history
      return if form_version&.editable?

      errors.add(:base, "published form fields cannot be deleted")
      throw :abort
    end
end
