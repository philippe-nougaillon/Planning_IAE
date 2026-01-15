namespace :examen do
  task rappel_examen_intervenant: :environment do
    # Envoyer ou relancer le lien du sujet aux intervenants
    jours_rappel = [60, 30, 20, 10, 7, 5, 3]

    examens_groupe = Cour
                .where("DATE(cours.debut) >= ?", Date.new(2025,12,01))
                .where(intervenant_id: [169, 1166])
                .order(:debut)
                .group_by { |cour| [cour.debut, cour.intervenant_binome_id, cour.nom] }

    examens_groupe.each do |data_examen, cours_examen|
      # Représente le premier cours associé à l'examen, en tant que model, comme les cours ont tous les caractéristiques d'un même examen 
      model_examen = cours_examen.first

      nombre_jours = model_examen.days_between_today_and_debut

      # Si le nombre de jours restant avant la date d'examen atteint le seuil de relance, envoyer le mail de rappel correspondant
      if jours_rappel.include?(nombre_jours)

        # Création du sujet si pas existant et affectation aux cours concernés
        sujet = model_examen.sujet
        unless sujet.present?
          sujet = Sujet.create
          cours_examen.each do |examen|
            examen.sujet_id = sujet.id
            examen.save(validate: false)
          end
        end
        
        # Le sujet doit avoir un workflow correspondant à une relance ou à envoyer ou non comforme
        if !['déposé', 'validé', 'archivé'].include?(sujet.workflow_state)
          SujetExamenJob.perform_later(model_examen, sujet, nombre_jours)
        end
      end
    end
  end

  task archiver_sujet_passe: :environment do
    examen_yesterday = Cour.where("DATE(cours.fin) < ?", Date.today).where(intervenant_id: [169, 1166])
    examen_yesterday.each do |cour|
      if sujet = cour.sujet
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