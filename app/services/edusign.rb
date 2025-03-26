class Edusign < ApplicationService

    def initialize(url)
        url = URI(url)
        @http = Net::HTTP.new(url.host, url.port)
        @http.use_ssl = true

        @request = Net::HTTP::Get.new(url)
        @request["accept"] = 'application/json'
        @request["content-type"] = 'application/json'
        @request["authorization"] = "Bearer #{ENV['EDUSIGN_API_KEY']}"

        puts "Initialisation de la requête terminée"
    end

    def get_response 
        response = JSON.parse(@http.request(@request).read_body)
        
        puts "Lancement de la requête terminée"

        response
    end

    def remplir_justificatif(j_object, j_json)
        j_object.catégorie = j_json["TYPE"]
        j_object.commentaires = j_json["COMMENT"]
        j_object.etudiant_id = Etudiant.find_by(edusign_id: j_json["STUDENT_ID"]).id
        j_object.file_url = j_json["FILE_URL"]
        j_object.edusign_created_at = j_json["DATE_CREATION"]
        j_object.accepte_le = j_json["REQUEST_DATE"]
        j_object.debut = j_json["START"]
        j_object.fin = j_json["END"]
        j_object.save
    end

    def remplir_attendance(attendance, attendance_edusign)
        attendance.état = attendance_edusign["state"]
        attendance.signée_le = attendance_edusign["timestamp"]
        attendance.justificatif_edusign_id = attendance_edusign["absenceId"]
        attendance.retard = attendance_edusign["delay"]
        attendance.exclu_le = attendance_edusign["excluded"]
        attendance.cour_id = Cour.find_by(edusign_id: attendance_edusign["courseId"]).id
        attendance.etudiant_id = Etudiant.find_by(edusign_id: attendance_edusign["studentId"]).id
        attendance.signature = attendance_edusign["signature"]
        attendance.save

        if attendance_edusign["signatureEmail"] != nil

            signature_email = SignatureEmail.find_by(attendance_id: attendance.id) || SignatureEmail.new(attendance_id: attendance.id)        
            signature_email.nb_envoyee = attendance_edusign["signatureEmail"]["nbSent"]
            signature_email.requete_edusign_id = attendance_edusign["signatureEmail"]["requestId"]
            signature_email.limite = attendance_edusign["signatureEmail"]["signUntil"]
            signature_email.second_envoi = attendance_edusign["signatureEmail"]["secondSend"]
            signature_email.envoi_email = attendance_edusign["signatureEmail"]["sendEmailDate"]
            signature_email.save

            attendance.signature_email_id = signature_email.id

            attendance.save
        end

        
    end



end