class Admin::SubmissionsController < Admin::BaseController
  PAGE_SIZE = 50

  before_action :set_submission, only: %i[show update destroy]

  def index
    scope = filtered_scope
    @page = [ params.fetch(:page, 1).to_i, 1 ].max
    @total_count = scope.count
    @submissions = scope.order(submitted_at: :desc)
      .offset((@page - 1) * PAGE_SIZE).limit(PAGE_SIZE)
  end

  def show
    @audit_events = current_organization.audit_events
      .where(auditable_type: "Submission", auditable_id: @submission.id)
      .includes(:user).order(created_at: :desc)
  end

  def update
    previous_status = @submission.status
    @submission.update!(status: params.require(:submission).permit(:status)[:status])
    AuditRecorder.record(
      organization: current_organization,
      user: Current.user,
      action: "submission.status_changed",
      auditable: @submission,
      metadata: { reference_number: @submission.reference_number, from: previous_status, to: @submission.status },
      ip: request.remote_ip
    )
    redirect_to admin_organization_submission_path(current_organization, @submission),
      notice: "Submission status updated."
  rescue ArgumentError, ActiveRecord::RecordInvalid
    redirect_to admin_organization_submission_path(current_organization, @submission),
      alert: "Choose a valid submission status."
  end

  def destroy
    reference_number = @submission.reference_number
    AuditRecorder.record(
      organization: current_organization,
      user: Current.user,
      action: "submission.deleted",
      auditable: @submission,
      metadata: { reference_number: reference_number },
      ip: request.remote_ip
    )
    @submission.destroy!
    redirect_to admin_organization_submissions_path(current_organization),
      notice: "Submission #{reference_number} was permanently deleted."
  end

  def export
    scope = filtered_scope.order(:submitted_at)
    AuditRecorder.record(
      organization: current_organization,
      user: Current.user,
      action: "submission.exported",
      metadata: { filters: filter_params.to_h, row_count: [ scope.count, SubmissionCsvExporter::MAX_ROWS ].min },
      ip: request.remote_ip
    )

    filename = "#{current_organization.slug}-submissions-#{Date.current.iso8601}.csv"
    headers["Content-Type"] = "text/csv; charset=utf-8"
    headers["Content-Disposition"] = %(attachment; filename="#{filename}")
    headers["X-Content-Type-Options"] = "nosniff"
    self.response_body = SubmissionCsvExporter.new(scope).each_line
  end

  private
    def set_submission
      @submission = current_organization.submissions
        .includes(form_version: :fields).find(params[:id])
    end

    def filtered_scope
      scope = current_organization.submissions.includes(:form_version)
      filters = filter_params
      scope = scope.where(reference_number: filters[:reference_number].to_s.strip.upcase) if filters[:reference_number].present?
      scope = scope.where(status: filters[:status]) if filters[:status].present? && filters[:status].in?(Submission.statuses.keys)
      scope = scope.where("submitted_at >= ?", Date.iso8601(filters[:from]).beginning_of_day) if filters[:from].present?
      scope = scope.where("submitted_at <= ?", Date.iso8601(filters[:to]).end_of_day) if filters[:to].present?
      scope
    rescue Date::Error
      scope.none
    end

    def filter_params
      params.permit(:reference_number, :status, :from, :to)
    end
end
