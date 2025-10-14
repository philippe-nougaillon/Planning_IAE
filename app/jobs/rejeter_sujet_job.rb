class RejeterSujetJob < ApplicationJob
    queue_as :mailers
  
    def perform(sujet)
        mailer_response = IntervenantMailer.rejet_sujet(sujet).deliver_now
        mail_log = MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: examen.intervenant_binome.email, subject: "Relance Sujet Examen")

        sujet.update(mail_log_id: mail_log.id)
    end
end