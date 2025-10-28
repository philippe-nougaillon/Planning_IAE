import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs";

// Connects to data-controller="send-otp-with-credentials"
export default class extends Controller {
  static targets = ["email", "password", "formCredentials", "otp", "btnConnexion"]
  
  send_otp(event){
    if(this.otpTarget.style.display != "none"){
      return;
    }
    
    const email = this.emailTarget.value
    const password = this.passwordTarget.value

    const crendentialsFormData = new FormData()
    crendentialsFormData.append("email", email)
    crendentialsFormData.append("password", password)

    // Dans l'action du controller user, vérifie les crendentials envoyés puis envoie par mail si la méthode de l'otp est par mail
    Rails.ajax({
      type: "POST",
      url:  "/users/send_otp.json",
      data: crendentialsFormData,
      success: (data) => {
        if(data.otp_required == true){
          this.otpTarget.style.display = "block"
          this.btnConnexionTarget.onclick = null
        } else {
          this.formCredentialsTarget.submit()
        }
      },
      error: (err) => {
        // Si problème avec les credentials, soumet le formulaire pour afficher les potentiels erreurs par le controller
        this.formCredentialsTarget.submit()
      }
    })
  }
}
