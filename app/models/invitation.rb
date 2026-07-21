class Invitation < ApplicationRecord
  LIFETIME = 7.days

  belongs_to :organization
  belongs_to :invited_by, class_name: "User"

  enum :role, { owner: 0, administrator: 1 }, default: :administrator

  normalizes :email_address, with: ->(value) { value.to_s.strip.downcase }
  generates_token_for :acceptance, expires_in: LIFETIME do
    [ email_address, accepted_at ]
  end

  before_validation :set_expiration, on: :create

  validates :email_address, presence: true, length: { maximum: 320 },
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, :expires_at, presence: true
  validates :email_address, uniqueness: {
    scope: :organization_id,
    conditions: -> { where(accepted_at: nil) }
  }

  scope :pending, -> { where(accepted_at: nil).where("expires_at > ?", Time.current) }

  def pending?
    accepted_at.nil? && expires_at.future?
  end

  private
    def set_expiration
      self.expires_at ||= LIFETIME.from_now
    end
end
