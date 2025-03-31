class Edusign < ApplicationService

    def initialize

    end

    def prepare_request(url, method)
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
        model.where(created_at: self.get_interval_of_time).where(edusign_id: nil)
    end

    def get_all_element_updated_today(model, record_ids = nil)
        model.where(updated_at: self.get_interval_of_time).where("created_at != updated_at").where.not(edusign_id: nil).where.not(id: record_ids)
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

    def import_justificatifs
        self.prepare_request("https://ext.edusign.fr/v1/justified-absence?page=0", 'Get')

        response = self.get_response

        if response["status"] == 'error'
            puts response['message']
            return
        end

        puts "Début de la récupération des justificatifs"

        justificatifs_edusign = response["result"]

        puts "#{justificatifs_edusign.count} justificatifs ont été reçu"

        justificatifs_edusign.each do |justificatif_edusign|

            if Justificatif.where(edusign_id: justificatif_edusign["ID"]).empty?
                new_justificatif = Justificatif.new
                new_justificatif.edusign_id = justificatif_edusign["ID"]
                self.remplir_justificatif(new_justificatif, justificatif_edusign)
            else
                justificatif = Justificatif.find_by(edusign_id: justificatif_edusign["ID"])
                self.remplir_justificatif(justificatif, justificatif_edusign)
            end

        end

        puts "Importation des justificatifs terminée"
    end

    def import_attendances
        self.prepare_request("https://ext.edusign.fr/v1/course", 'Get')

        response = self.get_response

        if response["status"] == 'error'
            puts response["message"]
            return
        end

        puts "Début de la récupération des présences"

        cours_edusign = response["result"]

        puts "#{cours_edusign.count} cours ont été reçu"

        cours_edusign.each do |cour_edusign|

            # Filtrer les cours avec un edusign_id
            if cour = Cour.find_by(edusign_id: cour_edusign["ID"])

                cour_edusign["STUDENTS"].each do |attendance_edusign|

                    #puts cour_edusign["STUDENTS"].pluck("_id")
                    etudiant = Etudiant.find_by(edusign_id: attendance_edusign["studentId"])
                    # STUDENTS dans les cours d'Edusign sont des attendances
                    if attendance = Attendance.find_by(edusign_id: attendance_edusign["_id"])
                        self.remplir_attendance(attendance, attendance_edusign)
                    else
                        new_attendance = Attendance.new(etudiant_id: etudiant.id, cour_id: cour.id)

                        self.remplir_attendance(new_attendance, attendance_edusign)
                    end
                end
            end
        end

        puts "Importation des présences terminée"
    end

    def export_cours(method, cours_ajoutés_ids = nil)
        self.prepare_request("https://ext.edusign.fr/v1/course", method)

        if method == 'Post'
            cours = self.get_all_element_created_today(Cour)
            puts "Début de l'ajout des cours"
        else
            cours = self.get_all_element_updated_today(Cour, cours_ajoutés_ids)
            puts "Début de la modification des cours"
        end

        puts "#{cours.count} cours ont été récupéré"

        cours.each do |cour|
            body =
              {"course":{
                "NAME": cour.nom.presence || 'sans nom',
                "START": cour.debut - 2.hour,
                "END": cour.fin - 2.hour,
                "PROFESSOR": Intervenant.find(cour.intervenant_id).edusign_id,
                "API_ID": cour.id,
                "NEED_STUDENTS_SIGNATURE": true,
                "SCHOOL_GROUP": [cour.formation.edusign_id]
                }
              }

            if method == 'Patch'
                body[:course].merge!({"ID": cour.edusign_id})
                body.merge!({"editSurveys": false})
            end

            response = self.prepare_body_request(body).get_response

            puts response["status"] == 'error' ?  "Error : #{response["message"]}" : "Exportation du cours #{cour.id} réussie"

            if method == 'Post'
                cour.edusign_id = response["result"]["ID"]
                cour.save
            end
        end

        puts "Exportation des cours terminée"

        cours.pluck(:id) if method == "Post"
    end

    def export_intervenants(method, intervenants_ajoutés_ids = nil)
        self.prepare_request("https://ext.edusign.fr/v1/professor", method)

        if method == 'Post'
            intervenants = self.get_all_element_created_today(Intervenant)
            puts "Début de l'ajout des intervenants"
        else
            intervenants = self.get_all_element_updated_today(Intervenant, intervenants_ajoutés_ids)
            puts "Début de la modification des intervenants"
        end

        puts "#{intervenants.count} intervenants ont été récupéré"

        intervenants.each do |intervenant|
            body =
              {"professor":{
                "FIRSTNAME": intervenant.prenom,
                "LASTNAME": intervenant.nom,
                "EMAIL": intervenant.email,
                "API_ID": intervenant.id
              }}

            if method == 'Post'
                body[:professor].merge!({"dontSendCredentials": true})
            else
                body[:professor].merge!({"ID": intervenant.edusign_id})
            end

            response = self.prepare_body_request(body).get_response

            puts response["status"] == 'error' ?  "Error : #{response["message"]}" : "Exportation de l'intervenant #{intervenant.id} réussie"

            if method == 'Post'
                intervenant.edusign_id = response["result"]["ID"]
                intervenant.save
            end
        end

        puts "Exportation des intervenants terminée"

        intervenants.pluck(:id) if method == "Post"
    end

    private

        def get_interval_of_time
            DateTime.now.beginning_of_day..DateTime.now.end_of_day
        end

end