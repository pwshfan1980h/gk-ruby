class Admin::InvitationsController < Admin::BaseController
  before_action :require_owner

  def create
    invitation = InvitationIssuer.new(
      organization: current_organization,
      invited_by: Current.user,
      email_address: params.require(:invitation).permit(:email_address)[:email_address]
    ).call
    AuditRecorder.record(
      organization: current_organization,
      user: Current.user,
      action: "administrator.invited",
      auditable: invitation,
      metadata: { email_address: invitation.email_address },
      ip: request.remote_ip
    )
    redirect_to admin_organization_path(current_organization), notice: "Administrator invitation sent."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to admin_organization_path(current_organization), alert: error.record.errors.full_messages.to_sentence
  end
end
