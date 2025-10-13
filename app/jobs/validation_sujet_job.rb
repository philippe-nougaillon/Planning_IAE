class ValidationSujetJob < ApplicationJob
    queue_as :mailers
  
    def perform(examen, nombre_jours)

        mailer_response = IntervenantMailer.validation_sujet(examen, nombre_jours).deliver_now
        mail_log = MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: examen.intervenant_binome.email, subject: "Validation Sujet Examen")
        
        sujet.relancer! if sujet.mail_log
        sujet.update(mail_log_id: mail_log.id)
    end
end