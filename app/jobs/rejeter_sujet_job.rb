class RejeterSujetJob < ApplicationJob
    queue_as :mailers
  
    def perform(sujet)
        examen = sujet.cour
        nombre_jours = examen.days_between_today_and_debut
        raisons = sujet.message

        mailer_response = IntervenantMailer.rejet_sujet(examen, nombre_jours, raisons, sujet).deliver_now
        mail_log = MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: examen.intervenant_binome.email, subject: "Relance Sujet Examen")

        sujet.update(mail_log_id: mail_log.id)
    end
end