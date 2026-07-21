class FormPublisher
  Result = Data.define(:published_version, :draft_version)

  def initialize(form:, actor:)
    @form = form
    @actor = actor
  end

  def call
    Form.transaction do
      form.lock!

      draft = form.versions.draft.includes(:fields).first!
      draft.validate!
      previous_publication = form.versions.published.first
      now = Time.current

      previous_publication&.update!(status: :archived)
      draft.update!(status: :published, published_at: now)

      next_draft = clone_as_draft(draft)
      record_audit_event(draft, previous_publication)

      Result.new(published_version: draft, draft_version: next_draft)
    end
  end

  private
    attr_reader :form, :actor

    def clone_as_draft(published)
      next_version = form.versions.maximum(:version_number) + 1
      draft = form.versions.create!(
        organization: form.organization,
        version_number: next_version,
        status: :draft,
        title: published.title,
        intro: published.intro,
        confirmation_message: published.confirmation_message,
        created_by: actor
      )

      published.fields.each do |field|
        draft.fields.create!(field.attributes.slice(
          "field_key", "field_type", "label", "help_text", "placeholder",
          "required", "position", "max_length", "options"
        ))
      end

      draft
    end

    def record_audit_event(published, previous_publication)
      AuditEvent.create!(
        organization: form.organization,
        user: actor,
        action: "form.published",
        auditable_type: "FormVersion",
        auditable_id: published.id,
        metadata: {
          version_number: published.version_number,
          replaced_version_number: previous_publication&.version_number
        }.compact
      )
    end
end
