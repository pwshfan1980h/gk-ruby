import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["picker", "text"]

  pickerChanged() {
    this.textTarget.value = this.pickerTarget.value.toUpperCase()
  }

  textChanged() {
    if (/^#[0-9A-Fa-f]{6}$/.test(this.textTarget.value)) {
      this.pickerTarget.value = this.textTarget.value.toUpperCase()
    }
  }

  usePreset(event) {
    const color = event.currentTarget.dataset.color
    this.pickerTarget.value = color
    this.textTarget.value = color
    this.textTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
