class AuditRecorder
  def self.record(organization:, action:, user: nil, auditable: nil, metadata: {}, ip: nil)
    AuditEvent.create!(
      organization: organization,
      user: user,
      action: action,
      auditable_type: auditable&.class&.base_class&.name,
      auditable_id: auditable&.id,
      metadata: metadata,
      ip_digest: PrivacyDigest.call(ip, purpose: "audit-ip")
    )
  end
end
