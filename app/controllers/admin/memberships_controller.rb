class Admin::MembershipsController < Admin::BaseController
  before_action :require_owner

  def destroy
    membership = current_organization.memberships.active.find(params[:id])
    if membership == current_membership
      redirect_to admin_organization_path(current_organization),
        alert: "You cannot deactivate your own administrator access."
      return
    end

    if membership.owner? && current_organization.memberships.active.owner.count == 1
      redirect_to admin_organization_path(current_organization),
        alert: "The organization must keep at least one owner."
      return
    end

    membership.update!(active: false)
    AuditRecorder.record(
      organization: current_organization,
      user: Current.user,
      action: "administrator.deactivated",
      auditable: membership,
      metadata: { deactivated_user_id: membership.user_id },
      ip: request.remote_ip
    )
    redirect_to admin_organization_path(current_organization),
      notice: "Administrator access deactivated."
  end
end
