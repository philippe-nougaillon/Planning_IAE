class InvitMailer < ApplicationMailer
  default from: 'IAE-Paris <planning-iae@philnoug.com>'

  def envoyer_invitation
    @invit = params[:invit]
    mail(to: @invit.intervenant.email, subject:"[PLANNING] Invitation à un/des nouveaux cours")
  end

  def validation_invitation
    @invit = params[:invit]
    mail(to: @invit.intervenant.email, subject:"[PLANNING] Validation du cours")
  end

  def rejet_invitation
    @invit = params[:invit]
    mail(to: @invit.intervenant.email, subject:"[PLANNING] Rejet du cours")
  end

  def confirmation_invitation
    @invit = params[:invit]
    mail(to: @invit.intervenant.email, subject:"[PLANNING] Confirmation du cours")
  end

  def informer_intervenant
    @intervenant = Intervenant.find(params[:intervenant_id])
    mail(to: @intervenant.email, subject: "[PLANNING] Cours confirmés")
  end
end
