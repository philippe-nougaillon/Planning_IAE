class DeposerSujetJob < ApplicationJob
    queue_as :mailers
  
    def perform(sujet, intervenant_id = 0)
        title = "[PLANNING] Sujet déposé pour l'examen du #{I18n.l sujet.cour.debut.to_date, format: :long} à #{I18n.l sujet.cour.debut, format: :heures_log}"
        mailer_response = IntervenantMailer.deposer_sujet(sujet, title).deliver_now
        mail_log = MailLog.create(user_id: intervenant_id, message_id: mailer_response.message_id, to: sujet.cour.formation.user.email, subject: "Sujet d'Examen déposé", title: title)
        
        sujet.update(mail_log_id: mail_log.id)
    end
end