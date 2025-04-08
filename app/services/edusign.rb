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

        puts "=" * 20
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
        if etudiant_id = Etudiant.find_by(edusign_id: justificatif_edusign["STUDENT_ID"]).id
            justificatif.edusign_id = justificatif_edusign["ID"]
            justificatif.commentaires = justificatif_edusign["COMMENT"]
            justificatif.etudiant_id = etudiant_id
            justificatif.file_url = justificatif_edusign["FILE_URL"]
            justificatif.edusign_created_at = justificatif_edusign["DATE_CREATION"]
            justificatif.accepte_le = justificatif_edusign["REQUEST_DATE"]
            justificatif.debut = justificatif_edusign["START"]
            justificatif.fin = justificatif_edusign["END"]
            justificatif.save

            justificatif_edusign_id = justificatif_edusign["TYPE"]

            # Correspond à une catégorie si elle existe chez nous, sinon nil
            catégorie_name = Motif.catégories[justificatif_edusign_id]

            if catégorie_name
                # Pour la création des premiers motifs dans les catégories, si pas encore créé
                create_motif(justificatif_edusign_id, catégorie_name)
            else
                # Pour la création d'un motif, si nouveau
                create_motif(justificatif_edusign_id, get_motif_name_from_edusign_id(justificatif_edusign_id))
            end

            justificatif.motif_id = Motif.find_by(edusign_id: justificatif_edusign_id).id
            justificatif.save
        else
            puts "Étudiant avec l'edusign_id n°#{justificatif_edusign["STUDENT_ID"]} pas trouvé"
        end
    end

    def remplir_attendance(attendance, attendance_edusign)
        cour_id = Cour.find_by(edusign_id: attendance_edusign["courseId"]).id
        etudiant_id = Etudiant.find_by(edusign_id: attendance_edusign["studentId"]).id
        if cour_id && etudiant_id
            attendance.edusign_id = attendance_edusign["_id"]
            attendance.état = attendance_edusign["state"]
            attendance.signée_le = attendance_edusign["timestamp"]
            attendance.justificatif_edusign_id = attendance_edusign["absenceId"]
            attendance.retard = attendance_edusign["delay"]
            attendance.exclu_le = attendance_edusign["excluded"]
            attendance.cour_id = cour_id
            attendance.etudiant_id = etudiant_id
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
    end

    def get_motifs_from_edusign
        self.prepare_request("https://ext.edusign.fr/v1/justified-absence/absence-reason", 'Get')

        response = self.get_response

        if response["status"] == 'error'
            puts response['message']
            return
        end

        motifs_edusign = response["result"]

        puts "#{motifs_edusign.count} motifs reçu"

        motifs_edusign
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
    
    def export_formations(method, formations_ajoutés_ids = nil)
        self.prepare_request("https://ext.edusign.fr/v1/group", method)
                
        if method == 'Post'
            formations = self.get_all_element_created_today(Formation)
            puts "Début de l'ajout des formations"
        else
            formations = self.get_all_element_updated_today(Formation, formations_ajoutés_ids)
            puts "Début de la modification des formations"
        end
        
        puts "#{formations.count} formations ont été récupéré : #{formations.pluck(:id, :nom)}"

        formations.each do |formation|
            body =
                {"group":{
                    "NAME": formation.nom,
                    "STUDENTS": formation.etudiants.pluck(:edusign_id).compact
                }}

            if method == 'Patch'
                body[:group].merge!({"ID": formation.edusign_id})
            end

            response = self.prepare_body_request(body).get_response

            puts response["status"] == 'error' ?  "Error : #{response["message"]}" : "Exportation de la formation #{formation.id}, #{formation.nom} réussie"

            if method == 'Post'
                formation.edusign_id = response["result"]["ID"]
                formation.save
            end
        end

        puts "Exportation des formations terminée"

        # La liste des formations pour ne pas update celles qui ont été créées aujourd'hui
        formations.pluck(:id) if method == "Post"
    end

    def export_etudiants(method, etudiants_ajoutés_ids = nil)
        self.prepare_request("https://ext.edusign.fr/v1/student", method)
        
        if method == 'Post'
            etudiants = self.get_all_element_created_today(Etudiant)
            puts "Début de l'ajout des etudiants"
        else
            etudiants = self.get_all_element_updated_today(Etudiant, etudiants_ajoutés_ids)
            puts "Début de la modification des etudiants"
        end
        
        puts "#{etudiants.count} etudiants ont été récupéré : #{etudiants.pluck(:id, :nom)}"

        etudiants.each do |etudiant|
            body =
                {"student":{
                "FIRSTNAME": etudiant.prénom,
                "LASTNAME": etudiant.nom,
                "EMAIL": etudiant.email,
                "API_ID": etudiant.id,
                "GROUPS": etudiant.formation&.edusign_id
                }}

            if method == 'Patch'
                body[:student].merge!({"ID": etudiant.edusign_id})
            end

            response = self.prepare_body_request(body).get_response

            puts response["status"] == 'error' ?  "Error : #{response["message"]}" : "Exportation de l'étudiant #{etudiant.id}, #{etudiant.nom} réussie"

            if method == 'Post'
                etudiant.edusign_id = response["result"]["ID"]
                etudiant.save
            end
        end

        puts "Exportation des étudiants terminée"

        # La liste des etudiants pour ne pas update ceux qui ont été créés aujourd'hui
        etudiants.pluck(:id) if method == "Post"
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

        puts "#{intervenants.count} intervenants ont été récupéré : #{intervenants.pluck(:id, :nom)}"

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

            puts response["status"] == 'error' ?  "Error : #{response["message"]}" : "Exportation de l'intervenant #{intervenant.id}, #{intervenant.nom} réussie"

            if method == 'Post'
                intervenant.edusign_id = response["result"]["ID"]
                intervenant.save
            end
        end

        puts "Exportation des intervenants terminée"

        # La liste des intervenants pour ne pas update ceux qui ont été créés aujourd'hui
        intervenants.pluck(:id) if method == "Post"
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

        puts "#{cours.count} cours ont été récupéré : #{cours.pluck(:id, :nom)}"

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

            puts response["status"] == 'error' ?  "Error : #{response["message"]}" : "Exportation du cours #{cour.id}, #{cour.nom} réussie"

            if method == 'Post'
                cour.edusign_id = response["result"]["ID"]
                cour.save
            end
        end

        puts "Exportation des cours terminée"

        # La liste des cours pour ne pas update ceux qui ont été créés aujourd'hui
        cours.pluck(:id) if method == "Post"
    end
    
    def get_motif_name_from_edusign_id(id)
        self.get_motifs_from_edusign.each do |motif|
            if motif["ID"] == id
                return motif["NAME"]
            end
        end
    end
    private

    def create_motif(justificatif_edusign_id, nom_motif)
        unless Motif.find_by(edusign_id: justificatif_edusign_id)
            motif = Motif.new
            motif.nom = nom_motif
            motif.edusign_id = justificatif_edusign_id
            motif.save
        end
    end

    def get_interval_of_time
        DateTime.now.beginning_of_day..DateTime.now.end_of_day
    end

end