class NotifierEtudiantsJob < ApplicationJob
    queue_as :default
  
    def perform(etudiant, le_cours, user_id)
        # Envoyer une notification à tous les étudiants
        mailer_response = EtudiantMailer.notifier_modification_cours(etudiant, le_cours).deliver_now
        MailLog.create(user_id: user_id, message_id:mailer_response.message_id, to:etudiant.email, subject: "Modification cours")
    end
end