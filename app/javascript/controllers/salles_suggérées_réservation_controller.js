import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs";

export default class extends Controller {
    static targets = ['formationId', 'sallesFormation']

    // Afficher les salles de la formation si elle est déjà sélectionné au chargement de la page
    connect() {
        this.get_salles_formation()
    }

    get_salles_formation() {
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

        salles_formation.innerHTML = '<span>Salles à choisir en priorité :</span>'

        if(data.length === 0){
            salles_formation.innerHTML += 'aucune'
            return
        }

        data.forEach((salle, index) => {
            let span = document.createElement("span")
            span.textContent = salle
            if(index<data.length-1){
                span.textContent += ", "
            }
            salles_formation.appendChild(span)
        })
    }
}
