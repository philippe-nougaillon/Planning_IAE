class Edusign < ApplicationService

    def initialize(url, method)
        url = URI(url)
        @http = Net::HTTP.new(url.host, url.port)
        @http.use_ssl = true

        case method
        when "Get"
            @request = Net::HTTP::Get.new(url)
        when "Post"
            @request = Net::HTTP::Post.new(url)
        when "Patch"
            @request = Net::HTTP::Patch.new(url)
        end

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

    def prepare_body_request(body)
        body[body.keys.first]["API_TYPE"] = "Aikku PLANN"

        @request.body = body.to_json

        self
    end

    def get_all_element_created_today(model)
        model.where(created_at: self.get_interval_of_time)
    end

    def get_all_element_updated_today(model)
        model.where(updated_at: self.get_interval_of_time).where("created_at != updated_at")
    end

    def remplir_justificatif(justificatif, justificatif_edusign)
        justificatif.edusign_id = justificatif_edusign["ID"]
        justificatif.catégorie = justificatif_edusign["TYPE"]
        justificatif.commentaires = justificatif_edusign["COMMENT"]
        justificatif.etudiant_id = Etudiant.find_by(edusign_id: justificatif_edusign["STUDENT_ID"]).id
        justificatif.file_url = justificatif_edusign["FILE_URL"]
        justificatif.edusign_created_at = justificatif_edusign["DATE_CREATION"]
        justificatif.accepte_le = justificatif_edusign["REQUEST_DATE"]
        justificatif.debut = justificatif_edusign["START"]
        justificatif.fin = justificatif_edusign["END"]
        justificatif.save
    end

    def remplir_attendance(attendance, attendance_edusign)
        attendance.edusign_id = attendance_edusign["_id"]
        attendance.état = attendance_edusign["state"]
        attendance.signée_le = attendance_edusign["timestamp"]
        attendance.justificatif_edusign_id = attendance_edusign["absenceId"]
        attendance.retard = attendance_edusign["delay"]
        attendance.exclu_le = attendance_edusign["excluded"]
        attendance.cour_id = Cour.find_by(edusign_id: attendance_edusign["courseId"]).id
        attendance.etudiant_id = Etudiant.find_by(edusign_id: attendance_edusign["studentId"]).id
        attendance.signature = attendance_edusign["signature"]


        if attendance_edusign["signatureEmail"] != nil
            # Sauvegarde l'attendance pour pouvoir la retrouver si elle vient d'être créé
            attendance.save

            signature_email = SignatureEmail.find_by(attendance_id: attendance.id) || SignatureEmail.new(attendance_id: attendance.id)        
            signature_email.nb_envoyee = attendance_edusign["signatureEmail"]["nbSent"]
            signature_email.requete_edusign_id = attendance_edusign["signatureEmail"]["requestId"]
            signature_email.limite = attendance_edusign["signatureEmail"]["signUntil"]
            signature_email.second_envoi = attendance_edusign["signatureEmail"]["secondSend"]
            signature_email.envoi_email = attendance_edusign["signatureEmail"]["sendEmailDate"]
            signature_email.save

            attendance.signature_email_id = signature_email.id
        else
            SignatureEmail.find_by(id: attendance.signature_email_id)&.destroy
            attendance.signature_email_id = nil
        end

        attendance.save
        
    end

    private

        def get_interval_of_time
            DateTime.now.beginning_of_day..DateTime.now.end_of_day
        end

end