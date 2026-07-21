import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["type", "choices", "choicesInput", "length", "lengthInput"]

  connect() {
    this.refresh()
  }

  refresh(event) {
    const type = this.typeTarget.value
    const usesChoices = ["select", "radio"].includes(type)
    const usesLength = ["short_text", "long_text"].includes(type)

    this.choicesTarget.hidden = !usesChoices
    this.choicesTarget.setAttribute("aria-hidden", String(!usesChoices))
    this.lengthTarget.hidden = !usesLength
    this.lengthTarget.setAttribute("aria-hidden", String(!usesLength))

    if (event) {
      if (!usesChoices) this.choicesInputTarget.value = ""
      if (!usesLength) this.lengthInputTarget.value = ""
    }
  }
}
