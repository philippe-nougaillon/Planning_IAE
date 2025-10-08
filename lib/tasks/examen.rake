namespace :examen do
  task rappel_examen_intervenant: :environment do
    jours_rappel = [60, 30, 20, 10, 5, 3, 2, 1]

    examens = Cour.where("DATE(cours.debut) >= ?", Date.today).where(intervenant_id: [169, 1166])

    examens.each do |examen|
      nombre_jours = examen.days_between_today_and_debut
      if jours_rappel.include?(nombre_jours)
        sujet = Sujet.find_or_create_by(cour_id: examen.id)
        if !['déposé', 'validé', 'archivé'].include?(sujet.workflow_state)
          mailer_response = IntervenantMailer.rappel_examen(examen.intervenant_binome, examen.debut, sujet, nombre_jours).deliver_now
          mail_log = MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: examen.intervenant_binome.email, subject: "Sujet Examen")
          
          sujet.relancer! if sujet.mail_log
          sujet.update(mail_log_id: mail_log.id)
        end
      end
    end
  end
end