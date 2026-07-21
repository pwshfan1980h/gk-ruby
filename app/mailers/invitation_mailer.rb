class InvitationMailer < ApplicationMailer
  def invite
    @invitation = params[:invitation]
    @token = params[:token]
    mail to: @invitation.email_address,
      subject: "You were invited to administer #{@invitation.organization.name}"
  end
end
