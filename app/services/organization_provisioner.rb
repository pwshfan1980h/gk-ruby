class OrganizationProvisioner
  DEFAULT_FIELDS = [
    { field_type: :select, label: "What is your complaint about?", required: true,
      options: [ "Service", "Billing", "Communication", "Staff conduct", "Other" ] },
    { field_type: :long_text, label: "What happened?", required: true,
      help_text: "Include the important facts and people involved.", max_length: 5_000 },
    { field_type: :date, label: "When did this happen?", required: false },
    { field_type: :email, label: "Email address", required: false,
      help_text: "Provide this only if you would like a response." },
    { field_type: :phone, label: "Telephone number", required: false },
    { field_type: :long_text, label: "What outcome would help?", required: false, max_length: 2_000 },
    { field_type: :simulated_file, label: "Supporting document", required: false,
      help_text: "Demo mode records file metadata only; it does not retain file contents." },
    { field_type: :checkbox, label: "I confirm this information is accurate", required: true }
  ].freeze

  def initialize(organization_name:, organization_slug:, admin_name:, admin_email:, admin_password:)
    @organization_name = organization_name
    @organization_slug = organization_slug
    @admin_name = admin_name
    @admin_email = admin_email
    @admin_password = admin_password
  end

  def call
    Organization.transaction do
      organization = Organization.create!(name: organization_name, slug: organization_slug)
      administrator = User.create!(
        name: admin_name,
        email_address: admin_email,
        password: admin_password,
        password_confirmation: admin_password
      )
      organization.memberships.create!(user: administrator, role: :owner)
      form = organization.create_form!(name: "Complaint form", slug: "complaint")
      draft = form.versions.create!(
        organization: organization,
        version_number: 1,
        status: :draft,
        title: "Tell us about your complaint",
        intro: "Use this form to explain what happened. Required questions are marked with an asterisk.",
        confirmation_message: "Thank you. Your complaint has been received.",
        created_by: administrator
      )
      DEFAULT_FIELDS.each_with_index do |attributes, position|
        draft.fields.create!(attributes.merge(position: position))
      end
      FormPublisher.new(form: form, actor: administrator).call
      organization
    end
  end

  private
    attr_reader :organization_name, :organization_slug, :admin_name, :admin_email, :admin_password
end
