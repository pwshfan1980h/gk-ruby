import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template", "item", "position", "destroy"]

  add() {
    if (this.visibleItems().length >= 30) {
      window.alert("A form can contain at most 30 fields.")
      return
    }

    const uniqueIndex = `${Date.now()}${Math.floor(Math.random() * 1000)}`
    this.listTarget.insertAdjacentHTML(
      "beforeend",
      this.templateTarget.innerHTML.replaceAll("NEW_RECORD", uniqueIndex)
    )
    this.updatePositions()
    this.visibleItems().at(-1)?.querySelector("input[type='text']")?.focus()
  }

  remove(event) {
    const item = event.currentTarget.closest("[data-form-builder-target='item']")
    const destroy = item.querySelector("[data-form-builder-target='destroy']")
    destroy.value = "1"
    item.hidden = true
    this.updatePositions()
  }

  moveUp(event) {
    const item = event.currentTarget.closest("[data-form-builder-target='item']")
    const previous = this.previousVisibleSibling(item)
    if (previous) this.listTarget.insertBefore(item, previous)
    this.updatePositions()
  }

  moveDown(event) {
    const item = event.currentTarget.closest("[data-form-builder-target='item']")
    const next = this.nextVisibleSibling(item)
    if (next) this.listTarget.insertBefore(next, item)
    this.updatePositions()
  }

  updatePositions() {
    this.visibleItems().forEach((item, index) => {
      item.querySelector("[data-form-builder-target='position']").value = index
    })
  }

  visibleItems() {
    return this.itemTargets.filter((item) => !item.hidden)
  }

  previousVisibleSibling(item) {
    let sibling = item.previousElementSibling
    while (sibling?.hidden) sibling = sibling.previousElementSibling
    return sibling
  }

  nextVisibleSibling(item) {
    let sibling = item.nextElementSibling
    while (sibling?.hidden) sibling = sibling.nextElementSibling
    return sibling
  }
}
