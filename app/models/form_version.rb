class FormVersion < ApplicationRecord
  MAX_FIELDS = 30
  IMMUTABLE_CONTENT_ATTRIBUTES = %w[
    title intro confirmation_message form_id organization_id version_number
  ].freeze

  belongs_to :organization
  belongs_to :form
  belongs_to :created_by, class_name: "User", optional: true
  has_many :fields, -> { order(:position, :id) },
    class_name: "FormField", dependent: :destroy, inverse_of: :form_version
  has_many :submissions, dependent: :restrict_with_exception

  enum :status, { draft: 0, published: 1, archived: 2 }, default: :draft

  accepts_nested_attributes_for :fields, allow_destroy: true,
    reject_if: :all_blank, limit: MAX_FIELDS

  validates :version_number, presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :form_id }
  validates :status, presence: true
  validates :title, presence: true, length: { maximum: 120 }
  validates :intro, length: { maximum: 2_000 }, allow_blank: true
  validates :confirmation_message, length: { maximum: 1_000 }, allow_blank: true
  validate :organization_matches_form
  validate :field_count_within_limit
  validate :published_content_is_immutable, on: :update

  before_destroy :prevent_destroying_public_history

  def editable?
    draft?
  end

  private
    def organization_matches_form
      return if form.nil? || organization_id == form.organization_id

      errors.add(:organization, "must own the form")
    end

    def field_count_within_limit
      kept_fields = fields.reject(&:marked_for_destruction?)
      errors.add(:fields, "cannot exceed #{MAX_FIELDS}") if kept_fields.size > MAX_FIELDS
    end

    def published_content_is_immutable
      return unless status_was.in?(%w[published archived])
      return if (changes.keys & IMMUTABLE_CONTENT_ATTRIBUTES).empty?

      errors.add(:base, "published form content cannot be changed")
    end

    def prevent_destroying_public_history
      return if draft?

      errors.add(:base, "published form history cannot be deleted")
      throw :abort
    end
end
