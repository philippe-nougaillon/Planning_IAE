namespace :examen do
  task rappel_examen_intervenant: :environment do
    jours_rappel = [60, 30, 20, 10, 5, 3, 2, 1]

    examens = Cour.where("DATE(cours.debut) >= ?", Date.today).where(intervenant_id: [169, 1166])

    examens.each do |examen|
      nombre_jours = examen.days_between_today_and_debut
      if jours_rappel.include?(nombre_jours)
        sujet = Sujet.find_or_create_by(cour_id: examen.id)
        if !['déposé', 'validé', 'archivé'].include?(sujet.workflow_state)
          SujetExamenJob.perform_later(examen, sujet, nombre_jours)
        end
      end
    end
  end

  task archiver_sujet_passe: :environment do
    examen_yesterday = Cour.where("DATE(cours.fin) <= ?", Date.today-1.day).where(intervenant_id: [169, 1166])
    examen_yesterday.each do |cour|
      if sujet = Sujet.find_by(cour_id: cour.id)

        # Archive le sujet des examens passés
        # Si l'archivage est impossible, on ne fait rien
        if sujet.can_archiver?
          sujet.archiver!
          sujet.sujet.purge
        end
      end
    end
  end
end