class Form < ApplicationRecord
  belongs_to :organization
  has_many :versions, class_name: "FormVersion", dependent: :restrict_with_exception

  normalizes :slug, with: ->(value) { value.to_s.strip.downcase.parameterize }

  validates :name, presence: true, length: { maximum: 120 }
  validates :slug, presence: true, length: { maximum: 80 },
    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ },
    uniqueness: { scope: :organization_id }
  validates :organization_id, uniqueness: true

  def draft_version
    versions.find_by(status: :draft)
  end

  def published_version
    versions.find_by(status: :published)
  end
end
