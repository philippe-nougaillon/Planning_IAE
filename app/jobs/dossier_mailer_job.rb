class DossierMailerJob < ApplicationJob
    queue_as :mailers
  
    def perform(dossier_id, user_id, mailer_method, état)
        dossier = Dossier.find(dossier_id)
        mailer_response = DossierMailer.with(dossier: dossier).public_send(mailer_method).deliver_now
        dossier.mail_log_id = MailLog.create(user_id: user_id, message_id: mailer_response.message_id, to: dossier.intervenant.email, subject: "Dossier de recrutement CEV (#{état})").id
        dossier.save
    end
end