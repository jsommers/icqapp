import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitButton", "status", "timestamp"]
  static values = {
    originalText: String
  }

  connect() {
    this.originalTextValue = this.submitButtonTarget.innerHTML
    this.formatTimestamp()
  }

  formatTimestamp() {
    if (this.hasTimestampTarget) {
      const date = new Date(this.timestampTarget.dataset.utc)
      this.timestampTarget.innerText = `Last updated: ${date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' })}`
    }
  }

  submitStart() {
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.innerHTML = `
      <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
      Saving...
    `
  }

  submitEnd(event) {
    this.submitButtonTarget.disabled = false
    
    if (event.detail.success) {
      this.showSuccess()
    } else {
      this.submitButtonTarget.innerHTML = this.originalTextValue
    }
  }

  showSuccess() {
    const originalContent = this.originalTextValue
    this.submitButtonTarget.classList.remove("btn-primary")
    this.submitButtonTarget.classList.add("btn-success")
    this.submitButtonTarget.innerHTML = `
      <svg class="octicon me-2" height="16" viewBox="0 0 16 16" width="16"><path d="M13.78 4.22a.75.75 0 0 1 0 1.06l-7.25 7.25a.75.75 0 0 1-1.06 0L2.22 9.28a.751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018L6 10.94l6.72-6.72a.75.75 0 0 1 1.06 0Z"></path></svg>
      Response Recorded!
    `

    setTimeout(() => {
      this.submitButtonTarget.classList.remove("btn-success")
      this.submitButtonTarget.classList.add("btn-primary")
      this.submitButtonTarget.innerHTML = originalContent
    }, 2000)
  }
}
