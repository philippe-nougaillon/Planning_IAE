class Edusign < ApplicationService

    def initialize
        @time_zone_difference = 2.hour
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
        when "Delete"
            @request = Net::HTTP::Delete.new(url)
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

            # Test justificatif_edusign["STUDENT_ID"] à retirer si ça ne peut jamais être vide côté Edusign
            if justificatif_edusign["STUDENT_ID"] && etudiant_id = Etudiant.find_by(edusign_id: justificatif_edusign["STUDENT_ID"])&.id
                justificatif = Justificatif.find_or_initialize_by(edusign_id: justificatif_edusign["ID"], etudiant_id: etudiant_id)
                self.remplir_justificatif(justificatif, justificatif_edusign)
            else
                puts "Étudiant avec l'edusign_id n° #{justificatif_edusign["STUDENT_ID"]} pas trouvé. Le justificatif n'est pas récupéré."
            end

        end

        puts "Importation des justificatifs terminée"
    end

    def remplir_justificatif(justificatif, justificatif_edusign)
        justificatif.edusign_id = justificatif_edusign["ID"]
        justificatif.commentaires = justificatif_edusign["COMMENT"]
        justificatif.file_url = justificatif_edusign["FILE_URL"]
        justificatif.edusign_created_at = justificatif_edusign["DATE_CREATION"].to_datetime + @time_zone_difference
        justificatif.accepte_le = justificatif_edusign["REQUEST_DATE"].to_datetime + @time_zone_difference
        justificatif.debut = justificatif_edusign["START"].to_datetime + @time_zone_difference
        justificatif.fin = justificatif_edusign["END"].to_datetime + @time_zone_difference
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
    end

    def get_motif_name_from_edusign_id(id)
        self.get_motifs_from_edusign.each do |motif|
            if motif["ID"] == id
                return motif["NAME"]
            end
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

                # STUDENTS dans les cours d'Edusign sont des attendances
                cour_edusign["STUDENTS"].each do |attendance_edusign|

                    # Cas où l'étudiant est créé côté Edusign ou l'étudiant recherché n'a pas d'edusign_id
                    if etudiant = Etudiant.find_by(edusign_id: attendance_edusign["studentId"])
                        attendance = Attendance.find_or_initialize_by(edusign_id: attendance_edusign["_id"], etudiant_id: etudiant.id, cour_id: cour.id)
                        self.remplir_attendance(attendance, attendance_edusign)
                    else
                        puts "Étudiant avec l'edusign_id n° #{attendance_edusign["studentId"]} pas trouvé. L'attendance n'est pas récupérée."
                    end
                end
            else
                puts "Cour avec l'edusign_id n° #{cour_edusign["ID"]} pas trouvé. L'attendance n'est pas récupérée."
            end
        end

        puts "Importation des présences terminée"
    end

    def remplir_attendance(attendance, attendance_edusign)
        attendance.état = attendance_edusign["state"]
        attendance.signée_le = attendance_edusign["timestamp"].to_datetime + @time_zone_difference if attendance_edusign["timestamp"]
        attendance.justificatif_edusign_id = attendance_edusign["absenceId"]
        attendance.retard = attendance_edusign["delay"]
        attendance.exclu_le = attendance_edusign["excluded"].to_datetime + @time_zone_difference if attendance_edusign["excluded"]
        attendance.signature = attendance_edusign["signature"]

        if attendance_edusign["signatureEmail"] != nil
            # Sauvegarde l'attendance pour pouvoir la retrouver si elle vient d'être créé
            attendance.save

            signature_email = SignatureEmail.find_by(attendance_id: attendance.id) || SignatureEmail.new(attendance_id: attendance.id)        
            signature_email.nb_envoyee = attendance_edusign["signatureEmail"]["nbSent"]
            signature_email.requete_edusign_id = attendance_edusign["signatureEmail"]["requestId"]
            signature_email.limite = attendance_edusign["signatureEmail"]["signUntil"].to_datetime + @time_zone_difference
            signature_email.second_envoi = attendance_edusign["signatureEmail"]["secondSend"]
            signature_email.envoi_email = attendance_edusign["signatureEmail"]["sendEmailDate"].to_datetime + @time_zone_difference
            signature_email.save

            attendance.signature_email_id = signature_email.id
        else
            SignatureEmail.find_by(id: attendance.signature_email_id)&.destroy
            attendance.signature_email_id = nil
        end

        attendance.save
    end
    
    def sync_formations(method, formations_ajoutés_ids = nil)
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
                    "STUDENTS": formation.etudiants.pluck(:edusign_id).compact,
                    "API_ID": formation.id
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

    def export_formation(formation_id)
        self.prepare_request("https://ext.edusign.fr/v1/student", 'Post')

        formation = Formation.find(formation_id)
        if formation.edusign_id == nil && formation.etudiants.count > 0
            body =
            {"group":{
                "NAME": formation.nom,
                "STUDENTS": formation.etudiants.pluck(:edusign_id).compact,
                "API_ID": formation.id
            }}

            response = self.prepare_body_request(body).get_response
    
            unless response["status"] == 'error'
                formation.edusign_id = response["result"]["ID"]
                formation.save
            end
        else
            response = {}
            response["status"] = 'error'
            response["message"] = formation.edusign_id ? "Formation déjà existante dans Edusign, #{formation.edusign_id}." : "La formation n'a pas d'étudiant."
        end

        response
    end

    def sync_etudiants(method, etudiants_ajoutés_ids = nil)
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

    def export_etudiant(etudiant_id)
        self.prepare_request("https://ext.edusign.fr/v1/student", 'Post')

        etudiant = Etudiant.find(etudiant_id)
        if etudiant.edusign_id == nil
            body =
            {"student":{
                "FIRSTNAME": etudiant.prénom,
                "LASTNAME": etudiant.nom,
                "EMAIL": etudiant.email,
                "API_ID": etudiant.id,
                "GROUPS": etudiant.formation&.edusign_id
            }}

            response = self.prepare_body_request(body).get_response
    
            # puts response["status"] == 'error' ?  "Error : #{response["message"]}" : "Exportation de l'étudiant #{etudiant.id}, #{etudiant.nom} réussie"
    
            unless response["status"] == 'error'
                etudiant.edusign_id = response["result"]["ID"]
                etudiant.save
            end
        else
            response = {}
            response["status"] = 'error'
            response["message"] = "Apprenant déjà existant sur Edusign,  #{etudiant.edusign_id}."
        end

        response
    end

    def sync_intervenants(method, intervenants_ajoutés_ids = nil)
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
                "API_ID": intervenant.slug
              }}

            if method == 'Post'
                body[:professor].merge!({"dontSendCredentials": false})
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

    def export_intervenant(intervenant_slug)
        self.prepare_request("https://ext.edusign.fr/v1/professor", 'Post')

        intervenant = Intervenant.find_by(slug: intervenant_slug)
        body =
          {"professor":{
            "FIRSTNAME": intervenant.prenom,
            "LASTNAME": intervenant.nom,
            "EMAIL": intervenant.email,
            "API_ID": intervenant.slug
          },
           "dontSendCredentials": false
          }

        response = self.prepare_body_request(body).get_response
        
        unless response["status"] == 'error'
            intervenant.edusign_id = response["result"]["ID"]
            intervenant.save
        end

        # return response["status"] == 'error' ?  "Error : #{response["message"]}" : "Exportation de l'intervenant #{intervenant.slug}, #{intervenant.nom} réussie"
        return response
    end

    def sync_cours(method, cours_ajoutés_ids = nil)
        self.prepare_request("https://ext.edusign.fr/v1/course", method)

        if method == 'Post'
            cours = self.get_all_element_created_today(Cour).where.not(etat: ["annulé", "reporté"])
            puts "Début de l'ajout des cours"
            cours_a_supprimer = nil
        else
            cours = self.get_all_element_updated_today(Cour, cours_ajoutés_ids)
            puts "Début de la modification des cours"
            cours_a_supprimer = cours.where(etat: ["annulé", "reporté"])
        end
        
        # Cours à créer / modifier du côté d'Edusign
        cours_a_envoyer = cours.where(etat: ["planifié", "confirmé", "à_réserver"])

        puts "#{cours.count} cours ont été récupéré : #{cours.pluck(:id, :nom)}"

        if cours_a_envoyer 
            cours_a_envoyer.each do |cour|
                body =
                {"course":{
                    "NAME": cour.nom.presence || 'sans nom',
                    "START": cour.debut - @time_zone_difference,
                    "END": cour.fin - @time_zone_difference,
                    "PROFESSOR": Intervenant.find_by(id: cour.intervenant_id)&.edusign_id || ENV['EDUSIGN_DEFAULT_INTERVENANT_ID'],
                    "PROFESSOR_2": Intervenant.find_by(id: cour.intervenant_binome_id)&.edusign_id,
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
        end
        
        if cours_a_supprimer
            cours_a_supprimer.each do |cour|

                if cour.edusign_id != nil
                    self.prepare_request("https://ext.edusign.fr/v1/course/#{cour.edusign_id}", "Delete")
            
                    cour.edusign_id = nil
                    cour.save
                                
                    response = self.get_response
                    
                    puts response["status"] == 'error' ?  "Error : #{response["message"]}" : "Exportation du cours #{cour.id}, #{cour.nom} pour la suppression réussie"
                end
            end
        end
        
        puts "Exportation des cours terminée"

        # La liste des cours pour ne pas update ceux qui ont été créés aujourd'hui
        cours_a_envoyer.pluck(:id) if method == "Post"
    end

    def remove_deleted_cours_in_edusign
        edusign_ids = Audited::Audit
            .where(auditable_type: "Cour")
            .where(action: "destroy")
            .where(created_at: get_interval_of_time)
            .pluck("audited_changes")
            .pluck("edusign_id")
            .compact

        edusign_ids.each do |edusign_id|

            self.prepare_request("https://ext.edusign.fr/v1/course/#{edusign_id}", "Delete")

            response = self.get_response
            
            puts response["status"] == 'error' ?  "Error : #{response["message"]}" : "Exportation du cours #{edusign_id} pour la suppression réussie"


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
        # Modifier le Scheduler en conséquence, pour éviter les duplications
        DateTime.now-1.day..DateTime.now
    end

end