import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="rejet-sujet"
export default class extends Controller {
  static targets = ["rejeterForm", "btnRejeter", "btnSubmit"]

  // beforeunload pour fermeture d’onglet, rafraîchissement, ou navigations hors du domaine
  // turbo:before-visit pour le changement de page
  // popstate pour revenir en arrière ou revenir en avant

  connect() {
    // Contient un boolean 
    this.lastClickedElement = false
    
    // Permet de stocker le dernier boutton cliqué pour éviter de faire un confirm sur le boutton submit
    document.addEventListener("click", this.storeLastClick, true)
    
    // On attache les événements quand le contrôleur se connecte
    window.addEventListener("beforeunload", this.confirmRejet)
    document.addEventListener("turbo:before-visit", this.confirmRejet)
    window.addEventListener("popstate", this.confirmRejet)
  }

  disconnect() {
    // Nettoyage important pour éviter les fuites d’événements
    document.removeEventListener("click", this.storeLastClick, true)
    window.removeEventListener("beforeunload", this.confirmRejet)
    document.removeEventListener("turbo:before-visit", this.confirmRejet)
    window.removeEventListener("popstate", this.confirmRejet)
  }


  showForm() {
    this.rejeterFormTarget.style.display = "block"
    this.btnRejeterTarget.disabled = true
  }

  storeLastClick = (event) => {
    this.lastClickedElement = event.target
  }

  confirmRejet = (event) => {
    // Vérifie si le formulaire est visible
    if (this.btnRejeterTarget.disabled && (this.lastClickedElement != this.btnSubmitTarget)) {
      const message = "Vous avez un formulaire de rejet du sujet ouvert. Êtes-vous sûr de vouloir quitter sans valider ?"

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
}
