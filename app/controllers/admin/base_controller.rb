class Admin::BaseController < ApplicationController
  before_action :set_current_organization, if: -> { organization_slug_parameter.present? }

  helper_method :current_organization, :current_membership

  private
    def set_current_organization
      Current.membership = Current.user.memberships.active
        .joins(:organization)
        .where(organizations: { active: true })
        .find_by!(organizations: { slug: organization_slug_parameter })
      Current.organization = Current.membership.organization
    end

    def organization_slug_parameter
      params[:organization_slug] || params[:organization_id] || params[:slug]
    end

    def current_organization
      Current.organization
    end

    def current_membership
      Current.membership
    end

    def require_owner
      return if current_membership&.owner?

      head :forbidden
    end
end
