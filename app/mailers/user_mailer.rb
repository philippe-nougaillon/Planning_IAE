# Encoding: utf-8

class UserMailer < ApplicationMailer
  default from: 'IAE-Paris <planning-iae@philnoug.com>'

  # Send Welcome Email once Member confirms the account
  def welcome_email(user_id, password)
    @user = User.find(user_id)
    @password = password
    mail(to: @user.email, bcc: 'philippe.nougaillon@gmail.com', subject: "Welcome to IAE-Planning !")
  end

  def cours_changed(cours_id, email, etat)
    @cours = Cour.find(cours_id)
    @etat = etat
  	mail(to: email , subject: "[PLANNING] Cours du #{l(@cours.debut, format: :long).humanize} (#{@cours.nom_ou_ue}) est #{@etat}")
  end

  def notifier_fin_envoi_prochains_cours(n)
    @envoyes = n
    mail( to: ["respfd.iae@univ-paris1.fr", "philippe.nougaillon@gmail.com"], 
          subject: "[PLANNING] Notifications intervenants envoyées avec succès")
  end

end