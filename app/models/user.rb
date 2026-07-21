class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :sent_invitations, class_name: "Invitation",
    foreign_key: :invited_by_id, dependent: :restrict_with_exception

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true, length: { maximum: 120 }
  validates :email_address, presence: true, length: { maximum: 320 },
    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 12, maximum: 72 }, if: -> { password.present? }
end
