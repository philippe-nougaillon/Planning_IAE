import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="new-fermetures-count"
export default class extends Controller {
  static targets = ['date', 'date_fin', 'nom', 'message', 'box', 'checkbox']
  connect() {
    console.log("Hello, Stimulus! FERMETURE !!!", this.element)
  }

  calc() {
    if (this.dateTarget.value != "" && this.date_finTarget.value != "" && this.nomTarget.value != "") {
      let date_debut = new Date(this.dateTarget.value)
      let date_fin = new Date(this.date_finTarget.value)
      if (date_fin >= date_debut) {
        var diff = (date_fin - date_debut) / (1000 * 60 * 60 * 24) + 1;

        this.checkboxTarget.disabled = false
        this.messageTarget.classList.add("text-error")
        this.messageTarget.innerHTML = "Confirmer la création de <b>" + diff +" jours</b> de fermeture ?"
      }
      else {
        this.checkboxTarget.disabled = true
        this.messageTarget.classList.add("text-error")
        this.messageTarget.innerHTML = "La date de fin doit être supérieure à la date de début"
      }
    }
  }




}
