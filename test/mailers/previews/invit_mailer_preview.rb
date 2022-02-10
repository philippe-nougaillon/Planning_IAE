# Preview all emails at http://localhost:3000/rails/mailers/invit_mailer
class InvitMailerPreview < ActionMailer::Preview
  def envoyer_invitation
    InvitMailer.with(invit: Invit.first).envoyer_invitation
  end

  def validation_invitation
    InvitMailer.with(invit: Invit.first).validation_invitation
  end

  def rejet_invitation
    InvitMailer.with(invit: Invit.first).rejet_invitation
  end

  def confirmation_invitation
    InvitMailer.with(invit: Invit.first).confirmation_invitation
  end

  def informer_intervenant
    InvitMailer.with(intervenant_id: Invit.first.intervenant.id).informer_intervenant
  end

end
