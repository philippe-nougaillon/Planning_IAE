class SujetExamenJob < ApplicationJob
    queue_as :mailers
  
    def perform(examen, sujet, nombre_jours)
        title = "[PLANNING] Rappel de votre examen à l'IAE Paris du #{I18n.l examen.debut.to_date, format: :long} à #{I18n.l examen.debut, format: :heures_log}"
        mailer_response = IntervenantMailer.rappel_examen(examen, sujet, nombre_jours, title).deliver_now
        mail_log = MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: examen.intervenant_binome.email, subject: "Sujet Examen", title: title)
        
        sujet.relancer! if sujet.mail_log
        sujet.update(mail_log_id: mail_log.id)
    end
end