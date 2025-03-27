namespace :edusign do
  task justificatifs: :environment do

    requete = Edusign.new("https://ext.edusign.fr/v1/justified-absence?page=0", 'Get')
    
    response = requete.get_response

    if response["status"] == 'error'
      puts response['message']
      next
    end

    justificatifs_edusign = response["result"]

    justificatifs_edusign.each do |justificatif_edusign|

      if Justificatif.where(edusign_id: justificatif_edusign["ID"]).empty?
        new_justificatif = Justificatif.new
        new_justificatif.edusign_id = justificatif_edusign["ID"]
        requete.remplir_justificatif(new_justificatif, justificatif_edusign)
      else
        justificatif = Justificatif.find_by(edusign_id: justificatif_edusign["ID"])
        requete.remplir_justificatif(justificatif, justificatif_edusign)
      end

    end
  end

  task attendance: :environment do
    requete = Edusign.new("https://ext.edusign.fr/v1/course", 'Get')

    response = requete.get_response
    
    if response["status"] == 'error'
      puts response["message"]
    end

    cours_edusign = response["result"]
    
    cours_edusign.each do |cour_edusign|
      
      # Filtrer les cours avec un edusign_id
      if cour = Cour.find_by(edusign_id: cour_edusign["ID"])

        cour_edusign["STUDENTS"].each do |attendance_edusign|

          #puts cour_edusign["STUDENTS"].pluck("_id")
          etudiant = Etudiant.find_by(edusign_id: attendance_edusign["studentId"])
          # STUDENTS dans les cours d'Edusign sont des attendances
          if attendance = Attendance.find_by(edusign_id: attendance_edusign["_id"])
            
            requete.remplir_attendance(attendance, attendance_edusign)
          else 
            new_attendance = Attendance.new(etudiant_id: etudiant.id, cour_id: cour.id)

            requete.remplir_attendance(new_attendance, attendance_edusign)
          end
        end
      end
      
    end
  end
end