class Admin::FormsController < Admin::BaseController
  before_action :set_form_and_draft

  def edit
  end

  def update
    organization_attributes = params.fetch(:organization, {}).permit(
      :name, :accent_color, :privacy_notice, :retention_days
    )

    ApplicationRecord.transaction do
      current_organization.update!(organization_attributes)
      @draft.update!(draft_params)
      normalize_field_positions!
      AuditRecorder.record(
        organization: current_organization,
        user: Current.user,
        action: "form.draft_updated",
        auditable: @draft,
        ip: request.remote_ip
      )
    end

    redirect_to edit_admin_organization_form_path(current_organization),
      notice: "Draft saved. The public form has not changed."
  rescue ActiveRecord::StaleObjectError
    @draft = @form.draft_version
    flash.now[:alert] = "Another administrator saved this draft first. Review their changes and try again."
    render :edit, status: :conflict
  rescue ActiveRecord::RecordInvalid => error
    error.record.errors.each { |validation_error| @draft.errors.import(validation_error) } unless error.record == @draft
    flash.now[:alert] = "Please correct the highlighted fields."
    render :edit, status: :unprocessable_content
  end

  def preview
    AuditRecorder.record(
      organization: current_organization,
      user: Current.user,
      action: "form.draft_previewed",
      auditable: @draft,
      ip: request.remote_ip
    )
    render "public_forms/show", locals: {
      organization: current_organization,
      form_version: @draft,
      submission: Submission.new,
      preview: true
    }
  end

  def publish
    result = FormPublisher.new(form: @form, actor: Current.user).call
    AuditRecorder.record(
      organization: current_organization,
      user: Current.user,
      action: "form.publish_requested",
      auditable: result.published_version,
      ip: request.remote_ip
    )
    redirect_to edit_admin_organization_form_path(current_organization),
      notice: "Version #{result.published_version.version_number} is now public. A new draft is ready."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to edit_admin_organization_form_path(current_organization),
      alert: error.record.errors.full_messages.to_sentence
  end

  private
    def set_form_and_draft
      @form = current_organization.form
      @draft = @form&.draft_version
      raise ActiveRecord::RecordNotFound unless @form && @draft
    end

    def draft_params
      params.require(:form_version).permit(
        :title, :intro, :confirmation_message, :lock_version,
        fields_attributes: [
          :id, :field_type, :label, :help_text, :placeholder, :required,
          :position, :max_length, :options_text, :_destroy
        ]
      )
    end

    def normalize_field_positions!
      @draft.fields.reload.each_with_index do |field, position|
        field.update_column(:position, position) unless field.position == position
      end
    end
end
