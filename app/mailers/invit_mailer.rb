class InvitMailer < ApplicationMailer
  default from: 'IAE-Paris <planning-iae@philnoug.com>'

  def envoyer_invitation
    @invit = params[:invit]
    mail(to: @invit.intervenant.email, 
         subject:"[PLANNING] Proposition de créneaux pour placer vos cours #{ @invit.cour.formation.nom } à l’IAE Paris-Sorbonne").tap do |message|
          message.mailgun_options = {
            "tag" => [@invit.intervenant.email, "invitation"]
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

  def informer_intervenant
    @intervenant = Intervenant.find(params[:intervenant_id])
    mail(to: @intervenant.email, subject: "[PLANNING] Cours confirmés à l’IAE Paris-Sorbonne")
  end

  def informer_gestionnaire
    @gestionnaire = User.find(params[:gestionnaire_id])
    mail(to: @gestionnaire.email, subject: "[PLANNING] Vous avez de nouvelles réponses à traiter")
  end

end
