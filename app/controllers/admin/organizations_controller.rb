class Admin::OrganizationsController < Admin::BaseController
  def index
    @memberships = Current.user.memberships.active.includes(:organization)
      .where(organizations: { active: true }).order("organizations.name")
  end

  def show
    @form = current_organization.form
    @recent_submissions = current_organization.submissions.order(submitted_at: :desc).limit(5)
  end
end
