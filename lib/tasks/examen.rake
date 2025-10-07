namespace :examen do
  task rappel_examen_intervenant: :environment do
    jours_rappel = [60, 30, 20, 10, 5, 3, 2, 1]
    
    Cour.where("cours.debut >= DATE(?)", DateTime.now).each do |cour|
      if cour.examen?
        nombre_jours = cour.debut.to_date - Date.today
        if jours_rappel.include?(nombre_jours)
          IntervenantMailer.rappel_examen(cour.intervenant_binome, cour.debut, nombre_jours).deliver_now
        end
      end
    end
  end
end