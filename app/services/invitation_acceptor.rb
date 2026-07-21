class InvitationAcceptor
  def initialize(invitation:, user_attributes:)
    @invitation = invitation
    @user_attributes = user_attributes
  end

  def call
    invitation.organization.with_lock do
      invitation.lock!
      raise ActiveRecord::RecordInvalid.new(invitation) unless invitation.pending?

      user = User.find_by(email_address: invitation.email_address)
      user ||= User.create!(user_attributes.merge(email_address: invitation.email_address))

      invitation.organization.memberships.create!(user: user, role: invitation.role)
      invitation.update!(accepted_at: Time.current)
      user
    end
  end

  private
    attr_reader :invitation, :user_attributes
end
