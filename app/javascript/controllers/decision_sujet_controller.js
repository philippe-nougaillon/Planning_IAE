import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="decision-sujet"
// Un bouton (Valider, Rejeter) ouvre son formulaire ; tant qu'il est ouvert et non envoyé,
// quitter la page demande confirmation.
export default class extends Controller {
  static targets = ["form", "btnOuvrir"]

  // beforeunload pour fermeture d’onglet, rafraîchissement, ou navigations hors du domaine
  // turbo:before-visit pour le changement de page
  // popstate pour revenir en arrière ou revenir en avant

  connect() {
    this.formOuvert = null

    this.element.addEventListener("submit", this.formEnvoye)
    window.addEventListener("beforeunload", this.confirmQuitter)
    document.addEventListener("turbo:before-visit", this.confirmQuitter)
    window.addEventListener("popstate", this.confirmQuitter)
  }

  disconnect() {
    // Nettoyage important pour éviter les fuites d’événements
    this.element.removeEventListener("submit", this.formEnvoye)
    window.removeEventListener("beforeunload", this.confirmQuitter)
    document.removeEventListener("turbo:before-visit", this.confirmQuitter)
    window.removeEventListener("popstate", this.confirmQuitter)
  }

  // data-decision-sujet-form-param donne l'id du formulaire à ouvrir
  showForm(event) {
    this.formOuvert = this.formTargets.find(form => form.id === event.params.form)
    this.formOuvert.style.display = "block"
    this.btnOuvrirTargets.forEach(btn => btn.disabled = true)
  }

  formEnvoye = () => {
    this.formOuvert = null
  }

  confirmQuitter = (event) => {
    if (!this.formOuvert) return

    const message = this.formOuvert.dataset.message

    // Cas 1 : navigation Turbo (liens internes)
    if (event.type === "turbo:before-visit") {
      if (!confirm(message)) {
        event.preventDefault() // bloque la navigation Turbo
      }
    }

    // Cas 2 : fermeture / rechargement de la page
    if (event.type === "beforeunload") {
      // navigateurs modernes exigent d’affecter `returnValue`
      event.preventDefault()
    }

    // Cas 3 : flèches navigateur (popstate)
    if (event.type === "popstate") {
      const confirmed = confirm(message)
      if (confirmed) {
        // On empêche le retour en repoussant l’état actuel
        history.pushState(null, "", window.location.href)
        history.back()
      }
    }
  }
}
