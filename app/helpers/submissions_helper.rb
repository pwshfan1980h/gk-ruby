module SubmissionsHelper
  def display_submission_answer(value)
    if value.is_a?(Hash) && value["simulated"]
      safe_join([
        content_tag(:span, value["filename"], class: "font-medium text-slate-900"),
        content_tag(:span, "Metadata only · #{number_to_human_size(value['byte_size'])} · #{value['content_type'].presence || 'unknown type'}", class: "block text-xs text-amber-700")
      ])
    elsif value == true
      "Yes"
    elsif value == false
      "No"
    else
      simple_format(value.to_s, {}, wrapper_tag: "div")
    end
  end

  def submission_status_classes(status)
    {
      "new_submission" => "bg-blue-100 text-blue-800",
      "in_review" => "bg-amber-100 text-amber-800",
      "resolved" => "bg-emerald-100 text-emerald-800"
    }.fetch(status)
  end
end
