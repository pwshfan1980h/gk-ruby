class InvitationAcceptancesController < ApplicationController
  allow_unauthenticated_access
  before_action :set_invitation

  def new
    @user = User.new(email_address: @invitation.email_address)
  end

  def create
    @user = InvitationAcceptor.new(
      invitation: @invitation,
      user_attributes: user_params
    ).call
    start_new_session_for(@user)
    redirect_to admin_organization_path(@invitation.organization),
      notice: "Your administrator account is ready."
  rescue ActiveRecord::RecordInvalid => error
    @user = error.record.is_a?(User) ? error.record : User.new(user_params)
    flash.now[:alert] = "Please correct the highlighted fields."
    render :new, status: :unprocessable_content
  end

  private
    def set_invitation
      @invitation = Invitation.find_by_token_for!(:acceptance, params[:token])
      raise ActiveSupport::MessageVerifier::InvalidSignature unless @invitation.pending?
    rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
      redirect_to new_session_path, alert: "This invitation is invalid or has expired."
    end

    def user_params
      params.require(:user).permit(:name, :password, :password_confirmation)
    end
end
