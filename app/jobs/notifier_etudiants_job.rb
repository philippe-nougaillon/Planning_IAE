class NotifierEtudiantsJob < ApplicationJob
    queue_as :default
  
    def perform(etudiant, le_cours, user_id)
        # Envoyer une notification à tous les étudiants
        title = "[PLANNING IAE Paris] Votre cours du #{I18n.l(le_cours.debut.to_date, format: :long)} a changé !"
        mailer_response = EtudiantMailer.notifier_modification_cours(etudiant, le_cours, title).deliver_now
        MailLog.create(user_id: user_id, message_id: mailer_response.message_id, to: etudiant.email, subject: "Modification cours", title: title)
    end
end