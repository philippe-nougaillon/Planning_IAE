import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="decision-sujet"
// Tant qu'un modal (Valider, Rejeter) est ouvert et son formulaire non envoyé,
// quitter la page demande confirmation.
export default class extends Controller {
  // beforeunload pour fermeture d’onglet, rafraîchissement, ou navigations hors du domaine
  // turbo:before-visit pour le changement de page
  // popstate pour revenir en arrière ou revenir en avant

  connect() {
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

  formEnvoye = (event) => {
    event.target.closest("dialog").close()
  }

  confirmQuitter = (event) => {
    const modal = this.element.querySelector("dialog[open]")
    if (!modal) return

    // Cas 1 : navigation Turbo (liens internes)
    if (event.type === "turbo:before-visit") {
      if (!confirm(modal.dataset.message)) {
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
      if (confirm(modal.dataset.message)) {
        // On empêche le retour en repoussant l’état actuel
        history.pushState(null, "", window.location.href)
        history.back()
      }
    }
  }
}
