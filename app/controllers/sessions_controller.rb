class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      user.memberships.active.includes(:organization).find_each do |membership|
        AuditRecorder.record(
          organization: membership.organization,
          user: user,
          action: "authentication.signed_in",
          ip: request.remote_ip
        )
      end
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    Current.user&.memberships&.active&.includes(:organization)&.find_each do |membership|
      AuditRecorder.record(
        organization: membership.organization,
        user: Current.user,
        action: "authentication.signed_out",
        ip: request.remote_ip
      )
    end
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
