import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs";

export default class extends Controller {
    static targets = ['formationId', 'sallesFormation', 'intervenantId', 'sallesIntervenant']
    // Récupérer la formation si modifié eet non vide

    get_salles_formation() {
        // Faire une requete ajax pour récupérer les salles favoris de la formation
        Rails.ajax({
            type: "GET",
            url: "/salles/favoris_formation.json",
            data: "formation_id=" + this.formationIdTarget.value,
            success: (data) => {
                this.afficher_salles_formation(data)
            }
        })
    }

    afficher_salles_formation(data) {
        const salles_formation = this.sallesFormationTarget
        salles_formation.innerHTML = ''
        data.forEach(salle => {
            let span = document.createElement("span")
            span.textContent = salle
            salles_formation.appendChild(span)
        })
    }

    // Faire pareil avec les intervenants

    get_salles_intervenant() {
        // Faire une requete ajax pour récupérer les salles favoris de l'intervenant
        Rails.ajax({
            type: "GET",
            url: "/salles/favoris_intervenant.json",
            data: "intervenant_id=" + this.intervenantIdTarget.value,
            success: (data) => {
                this.afficher_salles_intervenant(data)
            }
        })
    }

    afficher_salles_intervenant(data) {
        const salles_intervenant = this.sallesIntervenantTarget
        salles_intervenant.innerHTML = ''
        data.forEach(salle => {
            let span = document.createElement("span")
            span.textContent = salle
            salles_intervenant.appendChild(span)
        })
    }
}
