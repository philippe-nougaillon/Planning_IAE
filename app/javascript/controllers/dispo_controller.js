import { Controller } from "stimulus"
import Rails from "@rails/ujs";
import $ from 'jquery';

export default class extends Controller {
  static targets = [ 'id', 'date', 'duree', 'formation_id', 'intervenant_id', 'salles' ]

  connect() {
    $("#intervenant_id").on('select2:select', function () {
        //console.log("list item selected");
        let event = new Event('change', { bubbles: true }) // fire a native event
        this.dispatchEvent(event);
    });
  }

  show_dispo() {
    this.updateAvailableRooms()
  }
  
  toggleLoading() {
    this.targets.find("button").classList.toggle("is-loading")
  }
  
  updateAvailableRooms() {
    Rails.ajax({
      type: "GET",
      url:  "/salles/libres.json",
      data: "date=" + this.dateTarget.value
            + "&id=" + this.idTarget.value 
            + "&duree=" + this.dureeTarget.value
            + "&formation_id=" + this.formation_idTarget.value
            + "&intervenant_id=" + this.intervenant_idTarget.value,
      success: (data) => {
        this.refreshDropdownValues(data)
      }
    })
  }
  
  refreshDropdownValues(data) {
    this.sallesTarget.innerHTML = ""

    if (data.length > 0) {
      for(var i = 0; i < data.length; i++) {
        var opt = data[i]
        this.sallesTarget.innerHTML += "<option value=\"" + opt.id + "\">" + opt.nom + " (" + opt.places +"p)" + "</option>"
      }
    } else {
      this.sallesTarget.innerHTML += "<option disabled>Oups ! Aucune salle disponible... Vérifiez vos paramètres. </option>"
    }
  }
}

// https://gorails.com/forum/populate-dropdowns-based-on-selection-with-stimulus-js