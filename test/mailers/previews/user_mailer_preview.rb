# Preview all emails at http://localhost:3000/rails/mailers/dossier_mailer
class UserMailerPreview < ActionMailer::Preview

  def welcome_email
    UserMailer.welcome_email(User.last.id, SecureRandom.base64(12))
  end

  def cours_changed
    UserMailer.cours_changed(Cour.last.id, User.last.email, "annulé")
  end

end
