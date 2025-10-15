class ValidationSujetJob < ApplicationJob
    queue_as :mailers
  
    def perform(sujet)
        examen = sujet.cour
        nombre_jours = examen.days_between_today_and_debut

        title = "[PLANNING] Validation de votre dépôt de sujet pour votre examen à l'IAE Paris du #{I18n.l examen.debut.to_date, format: :long} à #{I18n.l examen.debut, format: :heures_log}"
        mailer_response = IntervenantMailer.validation_sujet(examen, nombre_jours, title).deliver_now
        mail_log = MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: examen.intervenant_binome.email, subject: "Validation Sujet Examen", title: title)
        
        sujet.update(mail_log_id: mail_log.id)
    end
end