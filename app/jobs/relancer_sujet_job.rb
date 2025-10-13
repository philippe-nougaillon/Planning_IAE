class RelancerSujetJob < ApplicationJob
    queue_as :mailers
  
    def perform(sujet)
        examen = sujet.cour
        nombre_jours = examen.days_between_today_and_debut
        nombre_relances = sujet.workflow_state
        puts "nombre relances : " + nombre_relances

        mailer_response = IntervenantMailer.relance_sujet(examen, sujet, nombre_jours, nombre_relances).deliver_now
        mail_log = MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: examen.intervenant_binome.email, subject: "Relance Sujet Examen")
        
        sujet.relancer! if sujet.mail_log
        sujet.update(mail_log_id: mail_log.id)
    end
end