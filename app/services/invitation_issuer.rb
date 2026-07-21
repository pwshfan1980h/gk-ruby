class InvitationIssuer
  ADMIN_LIMIT = 2

  def initialize(organization:, invited_by:, email_address:)
    @organization = organization
    @invited_by = invited_by
    @email_address = email_address
  end

  def call
    organization.with_lock do
      organization.invitations.where(accepted_at: nil)
        .where("expires_at <= ?", Time.current).delete_all
      occupied_seats = organization.memberships.active.count + organization.invitations.pending.count
      raise ActiveRecord::RecordInvalid.new(invitation_with_seat_error) if occupied_seats >= ADMIN_LIMIT

      invitation = organization.invitations.create!(
        invited_by: invited_by,
        email_address: email_address,
        role: :administrator
      )
      token = invitation.generate_token_for(:acceptance)
      InvitationMailer.with(invitation: invitation, token: token).invite.deliver_later
      invitation
    end
  end

  private
    attr_reader :organization, :invited_by, :email_address

    def invitation_with_seat_error
      Invitation.new.tap { |invitation| invitation.errors.add(:base, "This organization already uses both administrator seats") }
    end
end
