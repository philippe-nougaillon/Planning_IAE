import { Controller } from "stimulus"
import Rails from "@rails/ujs";
import $ from 'jquery';

export default class extends Controller {
    static targets = [ 'date', 'duree', 'formation_id', 'intervenant_id', 'salles', 'output' ]

    initialize() {
        this.clearResult()
    }

    connect() {
        console.log("Hello, Stimulus!", this.element)

        $("#intervenant_id").on('select2:select', function () {
            console.log("list item selected");
            let event = new Event('change', { bubbles: true }) // fire a native event
            this.dispatchEvent(event);
          });
    }

    // get date() {
    //     return this.targets.find("date").value
    // }

    // get duree() {
    //     return this.targets.find("duree").value
    // }

    // get formation_id() {
    //     return this.targets.find("formation_id").value
    // }

    click() {
        console.log("Click !")

        this.outputTarget.textContent =
            `Hello, Date: ${this.dateTarget.value} 
            | durée: ${this.dureeTarget.value}
            | formation_id: ${this.formation_idTarget.value}
            | intervenant_id: ${this.intervenant_idTarget.value}
            `
    }

    show_dispo() {
        console.log("Show_dispo!!")
        this.updateAvailableRooms()
    }
    
    toggleLoading() {
        this.targets.find("button").classList.toggle("is-loading")
    }
    
    updateAvailableRooms() {
        this.clearResult()
    
        Rails.ajax({
          type: "GET",
          url: "/salles/libres.json",
          data: "date=" + this.dateTarget.value 
                + "&duree=" + this.dureeTarget.value
                + "&formation_id=" + this.formation_idTarget.value
                + "&intervenant_id=" + this.intervenant_idTarget.value,
          success: (data) => {
            console.log('Available rooms loaded!')
            this.refreshDropdownValues(data)
          }
        })
    }
    
      refreshDropdownValues(data) {
        this.sallesTarget.innerHTML = ""
        for(var i = 0; i < data.length; i++) {
          var opt = data[i]
          this.sallesTarget.innerHTML += "<option value=\"" + opt.id + "\">" + opt.nom + "</option>"
        }
      }
    
      clearResult() {
        this.sallesTarget.innerHTML = ""
      }

}

// https://gorails.com/forum/populate-dropdowns-based-on-selection-with-stimulus-js