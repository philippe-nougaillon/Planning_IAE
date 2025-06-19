class Edusign < ApplicationService

    def initialize
        # Pour le décalage horaire des cours entre Planning et Edusign
        @time_zone_difference = 2.hour
        
        # Utilisés pour calculer le nombre d'éléments en erreur
        @nb_recovered_elements = 0
        @nb_sended_elements = 0
    end

    def call
        # Necessaire pour créer des formations sans étudiants et des formations avec que des étudiants déjà créés sur Edusign
        formations_ajoutés_ids = self.sync_formations("Post", nil)
    
        etudiants_ajoutés_ids = self.sync_etudiants("Post", nil)
    
        self.sync_etudiants("Patch", etudiants_ajoutés_ids)
    
        self.sync_formations("Patch", formations_ajoutés_ids)
    
        intervenants_ajoutés_ids = self.sync_intervenants("Post")
    
        self.sync_intervenants("Patch", intervenants_ajoutés_ids)
    
        cours_ajoutés_ids = self.sync_cours("Post")
    
        self.sync_cours("Patch", cours_ajoutés_ids)
    
        self.remove_deleted_and_unfollowed_cours_in_edusign
    end

    def initialisation
        # Récupérer toutes les formations cobayes
        # Necessaire pour créer des formations sans étudiants et des formations avec que des étudiants déjà créés sur Edusign

        # Faire un scope pour l'interval qui doit tout prendre
        # Faire un scope pour les cours qui doivent comprendre ceux commancant ajd

        @setup = true

        self.sync_formations("Post", nil)
        
        self.sync_etudiants("Post", nil)
    
        self.sync_intervenants("Post")
    
        self.sync_cours("Post")
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

        puts "=" * 100
        puts "Préparation de la communication de l'API Edusign"
    end

    def get_response
        response = JSON.parse(@http.request(@request).read_body)
        
        puts "Lancement de la requête terminée : "
        puts response

        response
    end

    def prepare_body_request(body)
        body[body.keys.first]["API_TYPE"] = "Aikku PLANN"

        @request.body = body.to_json

        self
    end

    def get_all_element_created_today(model)
        interval = self.get_interval_of_time

        if model == Formation
            model.where(
              id: Formation.cobayes_edusign,
              created_at: interval,
              edusign_id: nil
            )
        elsif [Etudiant, Cour].include?(model)
            model.where(
              formation_id: Formation.cobayes_edusign,
              created_at: interval,
              edusign_id: nil
            )
        elsif model == Intervenant
            
            # On sélectionne que les intervenants qui sont liés à une formation cobaye.
            # Pour cela, on va passer par les cours qui appartienent aux formations cobayes et correspondent à l'intervalle.
            # Pour les cours, on se base sur updated_at pour ne pas rater un changement d'intervenant ou un ajout d'intervenant binome.

            # Ce code est temporaire le temps que l'on sache à quel moment il faudra créer l'intervenant sur Edusign.
            intervenant_ids = Cour.where(
              updated_at: interval,
              formation_id: Formation.cobayes_edusign
            ).pluck(:intervenant_id, :intervenant_binome_id).flatten.compact.uniq

            model.where(id: intervenant_ids, edusign_id: nil)
        end
    end

    def get_all_element_updated_today(model, record_ids = nil)
        interval = self.get_interval_of_time

        if model == Formation
            model.where(
              id: Formation.cobayes_edusign,
              updated_at: interval,
            ).where.not(edusign_id: nil).where.not(id: record_ids)
        elsif [Etudiant, Cour].include?(model)
            model.where(
              formation_id: Formation.cobayes_edusign,
              updated_at: interval,
            ).where.not(edusign_id: nil).where.not(id: record_ids)
        elsif model == Intervenant
            # Un intervenant peut ne plus avoir de cours avec des formations cobayes. Comme la requête permet de savoir qu'il est actif sur le planning, on l'update quand même sur Edusiugn.
            model.where(updated_at: interval).where.not(edusign_id: nil).where.not(id: record_ids)
        end
    end

    def get_all_elements_for_initialisation(model)
        if model == Formation
            model.where(
              id: Formation.cobayes_edusign,
              edusign_id: nil
            )
        elsif model == Cour
            model.where(
              formation_id: Formation.cobayes_edusign,
              edusign_id: nil
            ).where("debut >= ?", DateTime.now)
        elsif model == Etudiant
            model.where(
              formation_id: Formation.cobayes_edusign,
              edusign_id: nil
            )
        elsif model == Intervenant
            
            # On sélectionne que les intervenants qui sont liés à une formation cobaye.
            # Pour cela, on va passer par les cours qui appartienent aux formations cobayes et correspondent à l'intervalle.
            # Pour les cours, on se base sur updated_at pour ne pas rater un changement d'intervenant ou un ajout d'intervenant binome.

            # Ce code est temporaire le temps que l'on sache à quel moment il faudra créer l'intervenant sur Edusign.
            intervenant_ids = Cour.where(
              formation_id: Formation.cobayes_edusign
            ).where("debut >= ?", DateTime.now).pluck(:intervenant_id, :intervenant_binome_id).flatten.compact.uniq

            model.where(id: intervenant_ids, edusign_id: nil)
        end
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
        if @setup
            formations = self.get_all_elements_for_initialisation(Formation)
            puts "Début de l'ajout des formations"
        else 
            if method == 'Post'
                formations = self.get_all_element_created_today(Formation)
                puts "Début de l'ajout des formations"
            else
                formations = self.get_all_element_updated_today(Formation, formations_ajoutés_ids)
                puts "Début de la modification des formations"
            end
        end
        
        puts "#{formations.count} formations ont été récupérés : #{formations.pluck(:id, :nom)}"

        @nb_recovered_elements += formations.count

        nb_audited = 0

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

            puts response["status"] == 'error' ?  "<strong>Error : #{response["message"]}</strong>" : "Exportation de la formation réussie : #{formation.id}, #{formation.nom} "

            if response["status"] == 'success' 
                if method == 'Post'
                    formation.edusign_id = response["result"]["ID"]
                    formation.save
                end
                nb_audited += 1
            end
        end

        puts "Exportation des formations terminée."
        puts "Formations #{method == 'Post' ? 'ajoutées' : "modifiées"} : #{nb_audited}"

        @nb_sended_elements += nb_audited

        # La liste des formations pour ne pas update celles qui ont été créées aujourd'hui
        formations.pluck(:id) if method == "Post"
    end

    def export_formation(formation_id)
        self.prepare_request("https://ext.edusign.fr/v1/student", 'Post')

        if formation = Formation.find(formation_id)
            @nb_recovered_elements += 1

            if formation.edusign_id == nil && formation.etudiants.count > 0
                body =
                  {"group":{
                    "NAME": formation.nom,
                    "STUDENTS": formation.etudiants.pluck(:edusign_id).compact,
                    "API_ID": formation.id
                  }}

                response = self.prepare_body_request(body).get_response

                puts response["status"] == 'error' ?  "<strong>Error : #{response["message"]}</strong>" : "Exportation de l'étudiant #{formation.id}, #{formation.nom} réussie"

                if response["status"] == 'success'
                    formation.edusign_id = response["result"]["ID"]
                    formation.save
                    @nb_sended_elements += 1
                end
            else
                message = formation.edusign_id ? "Formation déjà existante dans Edusign, #{formation.edusign_id}." : "La formation n'a pas d'étudiant."
                puts message

                response = {}
                response["status"] = 'error'
                response["message"] = message
            end
        else
            response = {}
            response["status"] = 'error'
            response["message"] = "Error : Aucune formation ne correspond à cet id : #{formation_id}"
        end

        response
    end

    def sync_etudiants(method, etudiants_ajoutés_ids = nil)
        self.prepare_request("https://ext.edusign.fr/v1/student", method)

        if @setup
            etudiants = self.get_all_elements_for_initialisation(Etudiant)
            puts "Début de l'ajout des etudiants"
        else 
            if method == 'Post'
                etudiants = self.get_all_element_created_today(Etudiant)
                puts "Début de l'ajout des etudiants"
            else
                etudiants = self.get_all_element_updated_today(Etudiant, etudiants_ajoutés_ids)
                puts "Début de la modification des etudiants"
            end
        end
        
        puts "#{etudiants.count} etudiants ont été récupéré : #{etudiants.pluck(:id, :nom)}"

        @nb_recovered_elements += etudiants.count

        nb_audited = 0

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

            puts response["status"] == 'error' ?  "<strong>Error : #{response["message"]}</strong>" : "Exportation de l'étudiant réussie : #{etudiant.id}, #{etudiant.nom} "

            if response["status"] == 'success' 
                if method == 'Post'
                    etudiant.edusign_id = response["result"]["ID"]
                    etudiant.save
                end
                nb_audited += 1
            end
        end

        puts "Exportation des étudiants terminée." 
        puts "Etudiants #{method == 'Post' ? 'ajoutés' : "modifiés"} : #{nb_audited}"
        
        @nb_sended_elements += nb_audited

        # La liste des etudiants pour ne pas update ceux qui ont été créés aujourd'hui
        etudiants.pluck(:id) if method == "Post"
    end

    def export_etudiant(etudiant_id)
        self.prepare_request("https://ext.edusign.fr/v1/student", 'Post')

        if etudiant = Etudiant.find(etudiant_id)
            @nb_recovered_elements += 1

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

                puts response["status"] == 'error' ?  "<strong>Error : #{response["message"]}</strong>" : "Exportation de l'étudiant #{etudiant.id}, #{etudiant.nom} réussie"

                if response["status"] == 'success'
                    etudiant.edusign_id = response["result"]["ID"]
                    etudiant.save
                    @nb_sended_elements += 1
                end
            else
                response = {}
                response["status"] = 'error'
                response["message"] = "Apprenant déjà existant sur Edusign,  #{etudiant.edusign_id}."
            end
        else
            response = {}
            response["status"] = 'error'
            response["message"] = "Error : Aucun étudiant ne correspond à cet id : #{etudiant_id}"
        end

        response
    end

    def sync_intervenants(method, intervenants_ajoutés_ids = nil)
        self.prepare_request("https://ext.edusign.fr/v1/professor", method)
        
        if @setup
            intervenants = self.get_all_elements_for_initialisation(Intervenant)
            puts "Début de l'ajout des intervenants"
        else 
            if method == 'Post'
                intervenants = self.get_all_element_created_today(Intervenant)
                puts "Début de l'ajout des intervenants"
            else
                intervenants = self.get_all_element_updated_today(Intervenant, intervenants_ajoutés_ids)
                puts "Début de la modification des intervenants"
            end
        end
        
        puts "#{intervenants.count} intervenants ont été récupéré : #{intervenants.pluck(:id, :nom)}"

        @nb_recovered_elements += intervenants.count

        nb_audited = 0

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

            puts response["status"] == 'error' ?  "<strong>Error : #{response["message"]}</strong>" : "Exportation de l'intervenant réussie :  #{intervenant.id}, #{intervenant.nom}"

            if response["status"] == 'success'
                if method == 'Post'
                    intervenant.edusign_id = response["result"]["ID"]
                    intervenant.save
                end
                nb_audited += 1
            end
        end

        puts "Exportation des intervenants terminée."
        puts "Intervenants #{method == 'Post' ? 'ajoutés' : "modifiés"} : #{nb_audited}"

        @nb_sended_elements += nb_audited

        # La liste des intervenants pour ne pas update ceux qui ont été créés aujourd'hui
        intervenants.pluck(:id) if method == "Post"
    end

    def export_intervenant(intervenant_slug)
        self.prepare_request("https://ext.edusign.fr/v1/professor", 'Post')

        if intervenant = Intervenant.find_by(slug: intervenant_slug)
            @nb_recovered_elements += 1

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

            puts response["status"] == 'error' ?  "<strong>Error : #{response["message"]}</strong>" : "Exportation de l'étudiant #{intervenant.id}, #{intervenant.nom} réussie"

            if response["status"] == 'success'
                intervenant.edusign_id = response["result"]["ID"]
                intervenant.save
                @nb_sended_elements += 1
            end
        else
            response = {}
            response["status"] = 'error'
            response["message"] = "Error : Aucun intervenant ne correspond à ce slug : #{intervenant_slug}"
        end

        response
    end

    def sync_cours(method, cours_ajoutés_ids = nil)
        self.prepare_request("https://ext.edusign.fr/v1/course", method)
        
        if @setup
            cours = self.get_all_elements_for_initialisation(Cour)
            puts "Début de l'ajout des cours"
            cours_a_supprimer = Cour.none
        else 
            if method == 'Post'
                cours = self.get_all_element_created_today(Cour).where.not(etat: ["annulé", "reporté"])
                puts "Début de l'ajout des cours"
                cours_a_supprimer = Cour.none
            else
                cours = self.get_all_element_updated_today(Cour, cours_ajoutés_ids)
                puts "Début de la modification des cours"
                cours_a_supprimer = cours.where(etat: ["annulé", "reporté"])
            end    
        end
        
        # Cours à créer / modifier du côté d'Edusign
        cours_a_envoyer = cours.where(etat: ["planifié", "confirmé", "à_réserver"])

        puts "#{cours.count} cours ont été récupéré : #{cours.pluck(:id, :nom)}"

        @nb_recovered_elements += cours.count

        nb_audited = 0

        if cours_a_envoyer 
            cours_a_envoyer.each do |cour|
                body =
                {"course":{
                    "NAME": "#{cour.formation.nom} - #{cour.nom_ou_ue}" || 'Nom du cours à valider',
                    "START": cour.debut - @time_zone_difference,
                    "END": cour.fin - @time_zone_difference,
                    "PROFESSOR": Intervenant.find_by(id: cour.intervenant_id)&.edusign_id || ENV['EDUSIGN_DEFAULT_INTERVENANT_ID'],
                    "PROFESSOR_2": Intervenant.find_by(id: cour.intervenant_binome_id)&.edusign_id,
                    "API_ID": cour.id,
                    "NEED_STUDENTS_SIGNATURE": true,
                    "CLASSROOM": cour.salle&.nom,
                    "SCHOOL_GROUP": [cour.formation.edusign_id]
                    }
                }

                if method == 'Patch'
                    body[:course].merge!({"ID": cour.edusign_id})
                    body.merge!({"editSurveys": false})
                end

                response = self.prepare_body_request(body).get_response

                puts response["status"] == 'error' ?  "<strong>Error : #{response["message"]}</strong>" : "Exportation du cours #{cour.id}, #{cour.nom} réussie"

                if response["status"] == 'success' 
                    if method == 'Post'
                        cour.edusign_id = response["result"]["ID"]
                        cour.save
                    end
                    nb_audited += 1
                end
            end
        end
        
        # Supprime les cours reportés ou annulés
        if cours_a_supprimer.any?
            puts "Début de la suppression des cours annulés ou reportés"
            puts "#{cours_a_supprimer.count} cours ont été récupéré : #{cours_a_supprimer.pluck(:id, :nom)}"
            
            cours_a_supprimer.each do |cour|

                if cour.edusign_id != nil
                    self.prepare_request("https://ext.edusign.fr/v1/course/#{cour.edusign_id}", "Delete")
            
                    cour.edusign_id = nil
                    cour.save
                                
                    response = self.get_response
                    
                    puts response["status"] == 'error' ?  "<strong>Error : #{response["message"]}</strong>" : "Exportation du cours #{cour.id}, #{cour.nom} pour la suppression réussie"
                    
                    if response["status"] == 'success'
                        nb_audited += 1
                    end
                end
            end
        end
        
        puts "Exportation des cours terminée."
        puts "Cours #{method == 'Post' ? 'ajoutés' : "modifiés"} #{cours_a_supprimer.any? ? '/ supprimés' : ''}: #{nb_audited}"

        @nb_sended_elements += nb_audited

        # La liste des cours pour ne pas update ceux qui ont été créés aujourd'hui
        cours_a_envoyer.pluck(:id) if method == "Post"
    end

    def export_cours(cours_id)
        self.prepare_request("https://ext.edusign.fr/v1/course", 'Post')

        if cours = Cour.find(cours_id)
            @nb_recovered_elements += 1

            body =
              {"course":{
                "NAME": "#{cours.formation.nom} - #{cours.nom_ou_ue}" || 'Nom du cours à valider',
                "START": cours.debut - @time_zone_difference,
                "END": cours.fin - @time_zone_difference,
                "PROFESSOR": Intervenant.find_by(id: cours.intervenant_id)&.edusign_id || ENV['EDUSIGN_DEFAULT_INTERVENANT_ID'],
                "PROFESSOR_2": Intervenant.find_by(id: cours.intervenant_binome_id)&.edusign_id,
                "API_ID": cours.id,
                "NEED_STUDENTS_SIGNATURE": true,
                "CLASSROOM": cours.salle&.nom,
                "SCHOOL_GROUP": [cours.formation.edusign_id]
              }
              }

            response = self.prepare_body_request(body).get_response

            puts response["status"] == 'error' ?  "<strong>Error : #{response["message"]}</strong>" : "Exportation de l'étudiant #{cours.id}, #{cours.nom} réussie"

            if response["status"] == 'success'
                @nb_sended_elements += 1
            end
        else
            response = {}
            response["status"] = 'error'
            response["message"] = "Error : Aucun cours ne correspond à cet id : #{cours_id}"
        end

        response
    end

    def remove_deleted_and_unfollowed_cours_in_edusign
        # Récupération des cours supprimés sur Planning
        edusign_ids = Audited::Audit
            .where(auditable_type: "Cour")
            .where(action: "destroy")
            .where(created_at: get_interval_of_time)
            .pluck("audited_changes")
            .pluck("edusign_id")
            .compact

        # Récupération des cours appartennant à une ancienne formation cobaye
        edusign_ids << Cour.where.not(edusign_id: nil).where.not(formation_id: Formation.cobayes_edusign)

        puts "Début de la suppression des cours supprimés"
        puts "#{edusign_ids.count} cours ont été récupéré : #{edusign_ids}"

        @nb_recovered_elements += edusign_ids.count
        
        nb_audited = 0

        edusign_ids.each do |edusign_id|

            self.prepare_request("https://ext.edusign.fr/v1/course/#{edusign_id}", "Delete")

            response = self.get_response
            
            puts response["status"] == 'error' ?  "<strong>Error : #{response["message"]}</strong>" : "Exportation du cours #{edusign_id} pour la suppression réussie"

            if response["status"] == 'success'
                nb_audited += 1
            end
        end

        @nb_sended_elements += nb_audited
    end

    def get_etat
        puts "=" * 100
        puts "===> Nombre d'éléments récupérés : #{@nb_recovered_elements}, nombre d'éléments envoyés : #{@nb_sended_elements}, nombre d'échecs : #{self.count_failure_elements}"

        # Modification de l'etat
        if @nb_recovered_elements != 0
            case self.count_failure_elements
            when 0
                0 # Success
            when @nb_recovered_elements
                2 # Echec
            else
                1 # Warning
            end
        else
            0
        end
    end

    def count_failure_elements
        @nb_recovered_elements - @nb_sended_elements
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