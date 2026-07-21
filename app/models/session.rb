class Session < ApplicationRecord
  belongs_to :user

  scope :active, -> { where("expires_at > ?", Time.current) }

  before_validation :set_expiration, on: :create

  validates :expires_at, presence: true
  validates :user_agent, length: { maximum: 500 }, allow_blank: true

  private
    def set_expiration
      self.expires_at ||= 14.days.from_now
    end
end
