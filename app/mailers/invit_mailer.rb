class InvitMailer < ApplicationMailer

  def envoyer_invitation
    @invit = params[:invit]
    mail(to: @invit.intervenant.email, 
         subject: params[:title]).tap do |message|
          message.mailgun_options = {
            "tag" => [@invit.intervenant.email, "invitation"]
          }
      end
  end

  def informer_intervenant
    @intervenant = Intervenant.find(params[:intervenant_id])
    mail(to: @intervenant.email, subject: "[PLANNING] Cours confirmés à l’IAE Paris-Sorbonne")
  end

  def informer_gestionnaire
    @gestionnaire = User.find(params[:gestionnaire_id])
    mail(to: @gestionnaire.email, subject: "[PLANNING] Vous avez de nouvelles réponses à traiter")
  end

  # Notifie le service des examens (ENV["EXAMEN_MAIL"]) de la réponse d'un surveillant
  # à une invitation de surveillance d'examen.
  def informer_examens
    @invit = params[:invit]
    mail(to: ENV["EXAMEN_MAIL"], subject: params[:title]).tap do |message|
      message.mailgun_options = {
        "tag" => [ENV["EXAMEN_MAIL"], "reponse_surveillant"]
      }
    end
  end

  # def validation_invitation
  #   @invit = params[:invit]
  #   mail(to: @invit.intervenant.email, subject:"[PLANNING] Validation du cours")
  # end

  # def rejet_invitation
  #   @invit = params[:invit]
  #   mail(to: @invit.intervenant.email, subject:"[PLANNING] Rejet du cours")
  # end

  # def confirmation_invitation
  #   @invit = params[:invit]
  #   mail(to: @invit.intervenant.email, subject:"[PLANNING] Confirmation du cours")
  # end

end
