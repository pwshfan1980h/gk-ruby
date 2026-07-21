class AuditEvent < ApplicationRecord
  belongs_to :organization
  belongs_to :user, optional: true

  validates :action, presence: true, length: { maximum: 100 }
  validate :metadata_is_an_object

  def readonly?
    persisted?
  end

  private
    def metadata_is_an_object
      errors.add(:metadata, "must be an object") unless metadata.is_a?(Hash)
    end
end
