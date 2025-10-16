class RejeterSujetJob < ApplicationJob
    queue_as :mailers
  
    def perform(sujet, user_id = 0)
        title = "[PLANNING] Rejet de votre dépôt de sujet pour votre examen à l'IAE Paris du #{I18n.l sujet.cour.debut.to_date, format: :long} à #{I18n.l sujet.cour.debut, format: :heures_log}"
        mailer_response = IntervenantMailer.rejet_sujet(sujet, title).deliver_now
        mail_log = MailLog.create(user_id: user_id, message_id: mailer_response.message_id, to: sujet.cour.intervenant_binome.email, subject: "Rejet Sujet Examen", title: title)

        sujet.update(mail_log_id: mail_log.id)
    end
end