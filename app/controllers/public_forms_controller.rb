class PublicFormsController < ApplicationController
  allow_unauthenticated_access
  rescue_from ActiveSupport::MessageVerifier::InvalidSignature,
    with: :handle_invalid_form_token
  before_action :set_organization
  before_action :set_current_public_version, only: :show
  before_action :set_version_from_token, only: :create
  before_action :set_confirmation_submission, only: :confirmation
  rate_limit to: 30, within: 10.minutes, only: :create,
    by: -> { "#{@organization.id}:#{PrivacyDigest.call(request.remote_ip, purpose: "public-rate-limit")}" },
    with: -> { render plain: "Please wait before submitting again.", status: :too_many_requests }

  def show
    @submission = Submission.new
    @form_token = PublicFormToken.generate(@form_version)
  end

  def create
    return head :no_content if params[:website].present?

    raise ActiveSupport::MessageVerifier::InvalidSignature if @form_rendered_at > 1.second.ago

    @submission = SubmissionCreator.new(
      organization: @organization,
      form_version: @form_version,
      answers: normalized_answers,
      request: request
    ).call

    redirect_to public_form_confirmation_path(
      organization_slug: @organization.slug,
      reference_number: @submission.reference_number
    ), status: :see_other
  rescue ActiveRecord::RecordInvalid => error
    @submission = error.record
    @form_token = PublicFormToken.generate(@form_version)
    flash.now[:alert] = "Please correct the highlighted fields."
    render :show, status: :unprocessable_content
  rescue SubmissionCreator::LimitReached
    render :unavailable, status: :too_many_requests
  end

  def confirmation
    @reference_number = params[:reference_number]
  end

  private
    def set_organization
      @organization = Organization.where(active: true).find_by!(slug: params[:organization_slug])
    end

    def set_current_public_version
      @form_version = @organization.form&.published_version
      raise ActiveRecord::RecordNotFound unless @form_version
    end

    def set_version_from_token
      payload = PublicFormToken.verify!(params[:form_token])
      @form_version = @organization.form_versions
        .where(status: %i[published archived]).find(payload.form_version_id)
      @form_rendered_at = payload.rendered_at
    end

    def set_confirmation_submission
      @submission = @organization.submissions.find_by!(reference_number: params[:reference_number])
      @form_version = @submission.form_version
      @reference_number = @submission.reference_number
    end

    def normalized_answers
      submitted_answers = params.dig(:submission, :answers)
      submitted_answers = submitted_answers.to_unsafe_h if submitted_answers.respond_to?(:to_unsafe_h)
      submitted_answers ||= {}

      @form_version.fields.each_with_object({}) do |field, safe_answers|
        value = submitted_answers[field.field_key]
        safe_answers[field.field_key] = normalize_answer(field, value)
      end
    end

    def normalize_answer(field, value)
      case field.field_type
      when "checkbox"
        ActiveModel::Type::Boolean.new.cast(value)
      when "simulated_file"
        simulated_file_metadata(value)
      else
        value.to_s.strip
      end
    end

    def simulated_file_metadata(value)
      return {} unless value.is_a?(ActionDispatch::Http::UploadedFile)

      {
        "filename" => File.basename(value.original_filename.to_s).first(255),
        "content_type" => value.content_type.to_s.first(100),
        "byte_size" => value.size,
        "simulated" => true
      }
    end

    def handle_invalid_form_token
      redirect_to public_form_path(organization_slug: @organization.slug),
        alert: "This form page expired. Please open it again before submitting."
    end
end
