class SujetExamenJob < ApplicationJob
    queue_as :mailers
  
    def perform(examen, sujet, nombre_jours)
        # Setup pour l'envoi du mail en fonction du nombre de jours restant
        title = "[PLANNING] Demande SUJET pour EXAMEN du #{I18n.l examen.debut.to_date, format: :long}"
        préfixe_title, method = case nombre_jours
        when 60
            ["", :demande_sujet]
        when 30
            ["RAPPEL 1 > ", :relance_sujet_30_jours]
        when 20
            ["RAPPEL 2 > ", :relance_sujet_20_jours]
        when 10
            ["RAPPEL 3 > ", :relance_sujet_10_jours]
        when 7
            ["RAPPEL 4 > ", :relance_sujet_7_jours]
        when 5
            ["RAPPEL 5 > ", :relance_sujet_5_jours]
        when 3
            ["DERNIÈRE RELANCE - RAPPEL 6 > ", :relance_sujet_3_jours]
        end
        # Ajout du préfixe du titre correspondant au nombre de jours restant
        title.insert(0, préfixe_title) 

        mailer_response = IntervenantMailer.public_send(method, sujet, title).deliver_now
        mail_log = MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: examen.intervenant_binome.email, subject: "Sujet Examen", title: title)
        
        # Ne pas mettre l'état 'relancé' lorsque le sujet vient d'être envoyé
        sujet.relancer! if sujet.mail_log
        sujet.update(mail_log_id: mail_log.id)
    end
end