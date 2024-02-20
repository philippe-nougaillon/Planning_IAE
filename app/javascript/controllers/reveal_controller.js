import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reveal"
export default class extends Controller {
  static targets = ["pannel_ue", "pannel_etudiants", "pannel_vacations"]

  connect() {
    // console.log("Hello, Stimulus reveal!", this.element)
  }

  openPannelUe() {
    this.pannel_ueTarget.classList.toggle("hidden")
  }

  openPannelEtudiants() {
    this.pannel_etudiantsTarget.classList.toggle("hidden")
  }

  openPannelVacations() {
    this.pannel_vacationsTarget.classList.toggle("hidden")
  }
}
