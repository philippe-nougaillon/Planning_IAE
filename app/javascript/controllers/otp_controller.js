import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs";

// Connects to data-controller="send-otp-with-credentials"
export default class extends Controller {
  static targets = ["email", "password", "credentials", "otp", "btnConnexion"]
  
  send_otp(event){
    if(this.otpTarget.style.display != "none"){
      return;
    }
    
    const email = this.emailTarget.value
    const password = this.passwordTarget.value

    const crendentialsFormData = new FormData()
    crendentialsFormData.append("email", email)
    crendentialsFormData.append("password", password)

    // Dans l'action du controller user, vérifier les crendentials envoyés puis envoyer par mail si c'est par mail
    Rails.ajax({
      type: "POST",
      url:  "/users/send_otp.json",
      data: crendentialsFormData,
      success: (data) => {
        console.log("Message :", data);
        this.otpTarget.style.display = "block"
        this.btnConnexionTarget.onclick = null
      },
      error: (err) => {
        console.error("Erreur :", err);
        // effacer pareil en cas d'erreur
      }
    })
  }
}
