class Organization < ApplicationRecord
  DEFAULT_ACCENT_COLOR = "#1D4ED8"

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_one :form, dependent: :restrict_with_exception
  has_many :form_versions, dependent: :restrict_with_exception
  has_many :submissions, dependent: :restrict_with_exception
  has_many :audit_events, dependent: :destroy
  has_many :invitations, dependent: :destroy

  normalizes :slug, with: ->(value) { value.to_s.strip.downcase.parameterize }
  normalizes :accent_color, with: ->(value) { value.to_s.upcase }

  validates :name, presence: true, length: { maximum: 120 }
  validates :slug, presence: true, length: { maximum: 80 },
    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }, uniqueness: true
  validates :accent_color, presence: true,
    format: { with: /\A#[0-9A-F]{6}\z/ }
  validates :retention_days, numericality: {
    only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 365
  }
  validates :monthly_submission_limit, numericality: {
    only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100_000
  }

  def to_param
    slug
  end
end
