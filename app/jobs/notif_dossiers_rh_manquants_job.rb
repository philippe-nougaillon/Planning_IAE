class NotifDossiersRhManquantsJob < ApplicationJob
    queue_as :mailers
  
    def perform(intervenants)
        title = "[Enseignement IAE-Paris #{ AppConstants::PÉRIODE }] Rappel intervention CEV sans dossier RH"
        mailer_response = DossierMailer.with(intervenants: intervenants, title: title).notif_dossiers_rh_manquants.deliver_now
        MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: "cev.iae@univ-paris1.fr, srh.iae@univ-paris1.fr", subject: "Rappel intervention CEV sans dossier RH", title: title)
    end
end