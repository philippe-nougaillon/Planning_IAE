import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs";

// Connects to data-controller="checkbox-select-for-examen"
export default class extends Controller {

  static targets = ["intervenant_id", "hss", "no_send_to_edusign"]

  select_checkboxes(){
    Rails.ajax({
      type: "GET",
      url:  "/intervenants/examen.json",
      data: "intervenant_id=" + this.intervenant_idTarget.value,
      success: (data) => {
        if(data === true){
          this.hssTarget.checked = true
          this.no_send_to_edusignTarget.checked = true
        }else{
          this.hssTarget.checked = false
          this.no_send_to_edusignTarget.checked = false
        }
      }
    })
  }
}
