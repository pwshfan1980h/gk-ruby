require "csv"

class SubmissionCsvExporter
  MAX_ROWS = 5_000
  BASE_HEADERS = [ "Reference", "Status", "Submitted at (UTC)", "Form version" ].freeze
  DANGEROUS_CELL_PREFIX = /\A[=+\-@\t\r]/

  def initialize(submissions)
    @submissions = submissions.limit(MAX_ROWS).includes(form_version: :fields)
  end

  def each_line
    return enum_for(:each_line) unless block_given?

    fields = export_fields
    yield CSV.generate_line(BASE_HEADERS + fields.map { |field| safe_cell(field.label) })
    submissions.find_each do |submission|
      base_values = [
        submission.reference_number,
        submission.status.humanize,
        submission.submitted_at.utc.iso8601,
        submission.form_version.version_number
      ]
      answers = fields.map { |field| safe_cell(display_answer(submission.answers[field.field_key])) }
      yield CSV.generate_line(base_values + answers)
    end
  end

  private
    attr_reader :submissions

    def export_fields
      version_ids = submissions.reorder(nil).distinct.pluck(:form_version_id)
      FormField.joins(:form_version)
        .where(form_version_id: version_ids)
        .order("form_versions.version_number DESC", :position)
        .to_a
        .uniq(&:field_key)
        .sort_by(&:position)
    end

    def display_answer(value)
      if value.is_a?(Hash) && value["simulated"]
        "#{value['filename']} (metadata only, #{value['byte_size']} bytes)"
      elsif value == true
        "Yes"
      elsif value == false
        "No"
      else
        value.to_s
      end
    end

    def safe_cell(value)
      string = value.to_s
      string.match?(DANGEROUS_CELL_PREFIX) ? "'#{string}" : string
    end
end
