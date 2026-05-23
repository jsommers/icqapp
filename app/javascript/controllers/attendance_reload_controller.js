import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="attendance-reload"
export default class extends Controller {
  connect() {
    const frame = this.element.closest("turbo-frame")
    if (frame) {
      frame.reload()
    }
  }
}
