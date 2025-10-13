import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="rejet-sujet"
export default class extends Controller {
  static targets = ["rejeterForm"]

  connect() {
    // Pour tester que le contrôleur est bien connecté
    this.rejeterFormTarget.style.display = "none"

    // // Attache les événements globaux
    // window.addEventListener("beforeunload", this.confirmRejet)
    // document.addEventListener("turbo:before-visit", this.confirmRejet)
  }

  showForm() {
    this.rejeterFormTarget.style.display = "block"
  }

  // confirmRejet = (event) => {
  //   if (this.rejeterFormTarget.style.display === "block") {
  //     const confirmQuitter = confirm("Vous avez un formulaire de rejet du sujet ouvert. Êtes-vous sûr de vouloir quitter sans valider ?")
  //     if (!confirmQuitter) {
  //       event.preventDefault(); // Bloque la navigation Turbo
  //     }
  //   }
  // }
}
