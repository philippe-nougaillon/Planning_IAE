import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "formation", "salle", "message" ]
  static values = { question: { type: String, default: "Enregistrer quand même ?" } }

  connect() {
    this.verifier()
  }

  verifier() {
    if (!this.hasMessageTarget) return
    const manque = this.placesManquantes()
    this.messageTarget.textContent = manque > 0 ? `Salle trop petite : manque ${manque} place.s` : ""
    this.messageTarget.classList.toggle("hidden", manque <= 0)
  }

  confirmer(event) {
    const manque = this.placesManquantes()
    if (manque > 0 && !confirm(`Salle trop petite : manque ${manque} place.s. ${this.questionValue}`)) {
      event.preventDefault()
    }
  }

  placesManquantes() {
    if (!this.hasFormationTarget || !this.hasSalleTarget) return 0
    const formation = this.formationTarget.selectedOptions[0]
    const salle = this.salleTarget.selectedOptions[0]
    if (!formation?.dataset.effectif || !salle?.dataset.places || salle.dataset.bloc == "Z") return 0
    return parseInt(formation.dataset.effectif) - parseInt(salle.dataset.places)
  }
}
