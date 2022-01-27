# Preview all emails at http://localhost:3000/rails/mailers/invit_mailer
class InvitMailerPreview < ActionMailer::Preview
  def envoyer_invitation
    InvitMailer.with(invit: Invit.last).envoyer_invitation
  end

  def confirmation_invitation
    InvitMailer.with(invit: Invit.last).confirmation_invitation
  end
end
