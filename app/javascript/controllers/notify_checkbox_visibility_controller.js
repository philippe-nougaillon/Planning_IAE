import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notify-checkbox-visibility"
export default class extends Controller {
  static targets = ['saveField', 'notifyField']
  connect() {
    console.log("Hello, Stimulus! NOTIFY CHECKBOX VISIBILITY !!!", this.element)
  }

  toggleVisibility(event) {
    if (event.target.value === "true") {
      this.notifyFieldTarget.classList.remove("hidden");
    } else {
      this.notifyFieldTarget.classList.add("hidden");
    }
  }
}
