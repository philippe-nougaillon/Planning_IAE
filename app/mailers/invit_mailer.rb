class InvitMailer < ApplicationMailer
  default from: 'IAE-Paris <planning-iae@philnoug.com>'

  def envoyer_invitation
    @invit = params[:invit]
    mail(to: @invit.intervenant.email, subject:"[PLANNING] Invitation à un/des nouveaux cours")
  end

  def confirmation_invitation
    @invit = params[:invit]
    mail(to: @invit.intervenant.email, subject:"[PLANNING] Confirmation du cours")
  end
end
