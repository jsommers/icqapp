import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="poll-result"
export default class extends Controller {
  static targets = ["responses"]

  toggle() {
    if (this.responsesTarget.style["display"] === "block") {
      this.responsesTarget.style["display"] = "none"
    } else {
      this.responsesTarget.style["display"] = "block"
    }
  }
}
