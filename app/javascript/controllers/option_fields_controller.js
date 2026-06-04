import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="option-fields"
// Bascule l'affichage entre le champ "description" (texte libre) et le champ
// "intervenant" (select) selon la catégorie d'option choisie.
// La catégorie "surveillance_2" affiche le select d'intervenant ; les autres
// catégories affichent le textarea de description.
export default class extends Controller {
  static targets = ["categorie", "descriptionField", "intervenantField", "description", "intervenant"]

  connect() {
    this.toggle()
  }

  toggle() {
    const isSurveillance2 = this.categorieTarget.value === "surveillance_2"

    this.descriptionFieldTarget.classList.toggle("hidden", isSurveillance2)
    this.intervenantFieldTarget.classList.toggle("hidden", !isSurveillance2)

    // On évite de bloquer la soumission via un champ "required" caché.
    if (this.hasDescriptionTarget) {
      this.descriptionTarget.required = !isSurveillance2
      this.descriptionTarget.disabled = isSurveillance2
    }
    if (this.hasIntervenantTarget) {
      this.intervenantTarget.required = isSurveillance2
      this.intervenantTarget.disabled = !isSurveillance2
    }
  }
}
