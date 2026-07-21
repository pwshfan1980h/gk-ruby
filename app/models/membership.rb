class Membership < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  enum :role, { owner: 0, administrator: 1 }, default: :administrator

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :organization_id }

  scope :active, -> { where(active: true) }
end
