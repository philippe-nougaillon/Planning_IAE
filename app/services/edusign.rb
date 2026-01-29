class Edusign < ApplicationService

    def initialize
        # Pour le décalage horaire des cours entre Planning et Edusign
        # N'est plus utilisé pour les cours, mais seulement pour les attendances/justificatifs
        @time_zone_difference = 1.hour

        # Utilisés pour calculer le nombre d'éléments en erreur
        @nb_recovered_elements = 0
        @nb_sended_elements = 0

        # Déclaré ici pour éviter de synchroniser des éléments deux fois (à cause de la prochaine synchronisation qui se base sur le created_at de la synchronisation)
        @interval_end = Time.zone.now

        # Par défaut, on considère qu'il n'y a pas de crash.
        @crash = false
    end

    def call
        # Necessaire pour créer des formations sans étudiants 
        # et des formations avec que des étudiants déjà créés sur Edusign

        self.sync_formations("Post")

        self.sync_etudiants("Post")

        self.sync_etudiants("Patch")

        self.sync_formations("Patch")

        # Ajout des intervenants avant les cours, 
        # sinon les cours qui n'ont pas d'intervenant créé sur Edusign, ne seront pas créés
        self.sync_intervenants("Post")

        self.sync_intervenants("Patch")

        self.sync_cours("Post")

        self.sync_cours("Patch")

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

        # Ajout des intervenants avant les cours, sinon les cours qui n'ont pas d'intervenant créé sur Edusign, ne seront pas créés
        self.sync_intervenants("Post", nil)

        self.sync_cours("Post", nil)
    end

    def prepare_request_with_message(url, method)
        puts "=" * 100
        puts "Préparation de la communication de l'API Edusign"

        prepare_request(url, method)
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
    end

    def get_response(debug_mode = true)
        response = {}

        http_response = @http.request(@request)

        # Si le code de réponse est un succes, on parse la réponse
        if http_response.code.to_i == 200
            response = JSON.parse(http_response.body)

            if debug_mode
                puts "Lancement de la requête terminée : "
                puts response
            end
        else
            # Si ce n'est pas un succes, on considère que c'est un crash, et qu'il faudra refaire une tentative
            @crash = true
            response["status"] = "error"
            response["message"] = http_response.body
        end

        response
    end

    def prepare_body_request(body)
        body[body.keys.first]["API_TYPE"] = "Aikku PLANN"

        @request.body = body.to_json

        self
    end

    def get_interval_of_time
        # Se base sur le dernier EdusignLog où il n'y a pas eu de crash. Le scheduler n'est plus à synchroniser avec cette fonction
        puts "INTERVAL = #{EdusignLog.where(modele_type: 1).where.not(etat: 3).reorder(created_at: :desc).first.created_at..@interval_end}"
        EdusignLog.where(modele_type: 1).where.not(etat: 3).reorder(created_at: :desc).first.created_at..@interval_end
    end

    # Cette fonction prend les éléments qui sont considérés comme élément à ajouter sur edusign
    def get_all_elements_to_post(model_name)
        formations_sent_to_edusign_ids = Formation.not_archived.sent_to_edusign_ids

        case model_name
        when "Formation"
            Formation.where(
              edusign_id: nil,
              send_to_edusign: true
            )
        when "Etudiant"
            Etudiant.where(
              formation_id: formations_sent_to_edusign_ids,
              edusign_id: nil
            )
        when "Cour"
            Cour.where(
              formation_id: formations_sent_to_edusign_ids,
              edusign_id: nil,
              no_send_to_edusign: [false, nil]
            ).where.not(intervenant_id: Intervenant.examens_ids + Intervenant.sans_intervenant)
        when "Intervenant"
            # On sélectionne que les intervenants qui sont liés à une formation qui doit être sur Edusign.
            # Pour cela, on va passer par les cours qui appartienent à ces formations.

            intervenant_ids = Cour.where(
              formation_id: formations_sent_to_edusign_ids,
              no_send_to_edusign: [false, nil]
            ).pluck(:intervenant_id, :intervenant_binome_id).flatten.compact.uniq

            Intervenant.where(id: intervenant_ids, edusign_id: nil).where.not(id: Intervenant.examens_ids + Intervenant.sans_intervenant)
        end
    end

    # Récupère tous les éléments déjà sur Edusign, qui ont été modifiés depuis la dernière synchronisation sur AIKKU Plann
    def get_all_elements_updated_since_last_sync(model_name)
        interval = self.get_interval_of_time

        formations_sent_to_edusign_ids = Formation.not_archived.sent_to_edusign_ids

        case model_name
        when "Formation"
            Formation.where(
              updated_at: interval,
              send_to_edusign: true
            ).where.not(edusign_id: nil)
        when "Etudiant"
            Etudiant.where(
              formation_id: formations_sent_to_edusign_ids,
              updated_at: interval
            ).where.not(edusign_id: nil)
        when "Cour"
            Cour.where(
              formation_id: formations_sent_to_edusign_ids,
              updated_at: interval,
              no_send_to_edusign: [false, nil]
              ).where.not(edusign_id: nil)
              .where.not(intervenant_id: Intervenant.examens_ids + Intervenant.sans_intervenant)
        when "Intervenant"
            # Un intervenant peut ne plus avoir de cours avec des formations cobayes. Comme la requête permet de savoir qu'il est actif sur le planning, on l'update quand même sur Edusiugn.
            Intervenant.where(updated_at: interval).where.not(edusign_id: nil)
        end
    end

    def get_all_elements_for_initialisation(model_name)
        formations_sent_to_edusign_ids = Formation.not_archived.sent_to_edusign_ids
        case model_name
        when "Formation"
            Formation.where(
              edusign_id: nil,
              send_to_edusign: true
            )
        when "Cour"
            Cour.where(
              formation_id: formations_sent_to_edusign_ids,
              edusign_id: nil,
              no_send_to_edusign: [false, nil]
            ).where("debut >= ?", DateTime.now)
              .where.not(intervenant_id: Intervenant.examens_ids + Intervenant.sans_intervenant)
        when "Etudiant"
            Etudiant.where(
              formation_id: formations_sent_to_edusign_ids,
              edusign_id: nil
            )
        when "Intervenant"

            # On sélectionne que les intervenants qui sont liés à une formation cobaye.
            # Pour cela, on va passer par les cours qui appartienent aux formations cobayes et correspondent à l'intervalle.
            # Pour les cours, on se base sur updated_at pour ne pas rater un changement d'intervenant ou un ajout d'intervenant binome.

            intervenant_ids = Cour.where(
              formation_id: formations_sent_to_edusign_ids,
              no_send_to_edusign: [false, nil]
            ).where("debut >= ?", DateTime.now).pluck(:intervenant_id, :intervenant_binome_id).flatten.compact.uniq

            Intervenant.where(id: intervenant_ids, edusign_id: nil).where.not(id: Intervenant.examens_ids + Intervenant.sans_intervenant)
        end
    end

    def import_justificatifs
        self.prepare_request_with_message("https://ext.edusign.fr/v1/justified-absence?page=0", 'Get')

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
        self.prepare_request_with_message("https://ext.edusign.fr/v1/justified-absence/absence-reason", 'Get')

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
        self.prepare_request_with_message("https://ext.edusign.fr/v1/course?start=#{(Date.today-90.days).iso8601}&end=#{Date.today.iso8601}", 'Get')

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

    def sync_formations(method)
        self.prepare_request_with_message("https://ext.edusign.fr/v1/group", method)
        if @setup
            formations = self.get_all_elements_for_initialisation("Formation")
            puts "Début de l'ajout des formations (initialisation)"
        else
            if method == 'Post'
                formations = self.get_all_elements_to_post("Formation")
                puts "Début de l'ajout des formations"
            else
                formations = self.get_all_elements_updated_since_last_sync("Formation")
                puts "Début de la modification des formations"
            end
        end

        puts "#{formations.count} formations ont été récupérés : #{formations.pluck(:id, :nom)}"

        @nb_recovered_elements += formations.count

        nb_audited = 0

        formations.each do |formation|
            if formation.valid?
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

                puts response["status"] == 'error' ?  "<strong>Erreur d'exportation de la formation #{formation.id}, #{formation.nom} : #{response["message"]}</strong>" : "Exportation de la formation réussie : #{formation.id}, #{formation.nom}"

                if response["status"] == 'success'
                    if method == 'Post'
                        formation.update_attribute('edusign_id', response["result"]["ID"])
                    end
                    nb_audited += 1
                end
            else
                puts "La formation #{formation.id}, #{formation.nom} n'est pas valide, elle ne peut pas être envoyée dans Edusign : #{formation.errors.full_messages}"
            end
        end

        puts "Exportation des formations terminée."
        puts "Formations #{method == 'Post' ? 'ajoutées' : "modifiées"} : #{nb_audited}"

        @nb_sended_elements += nb_audited
    end

    def sync_etudiants(method)
        self.prepare_request_with_message("https://ext.edusign.fr/v1/student", method)

        if @setup
            etudiants = self.get_all_elements_for_initialisation("Etudiant")
            puts "Début de l'ajout des etudiants (initialisation)"
        else
            if method == 'Post'
                etudiants = self.get_all_elements_to_post("Etudiant")
                puts "Début de l'ajout des etudiants"
            else
                etudiants = self.get_all_elements_updated_since_last_sync("Etudiant")
                puts "Début de la modification des etudiants"
            end
        end

        puts "#{etudiants.count} etudiants ont été récupérés : #{etudiants.pluck(:id, :nom)}"

        @nb_recovered_elements += etudiants.count

        nb_audited = 0

        etudiants.each do |etudiant|
            if etudiant.valid?
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

                puts response["status"] == 'error' ?  "<strong>Erreur d'exportation de l'étudiant #{etudiant.id}, #{etudiant.nom_prénom} : #{response["message"]}</strong>" : "Exportation de l'étudiant réussie : #{etudiant.id}, #{etudiant.nom_prénom} "

                if response["status"] == 'success'
                    if method == 'Post'
                        etudiant.update_attribute('edusign_id', response["result"]["ID"])
                    end
                    nb_audited += 1
                end
            else
                puts "L'étudiant #{etudiant.id}, #{etudiant.nom} n'est pas valide, il ne peut pas être envoyé dans Edusign : #{etudiant.errors.full_messages}"
            end
        end

        puts "Exportation des étudiants terminée."
        puts "Etudiants #{method == 'Post' ? 'ajoutés' : "modifiés"} : #{nb_audited}"
        
        @nb_sended_elements += nb_audited
    end

    def sync_intervenants(method)
        self.prepare_request_with_message("https://ext.edusign.fr/v1/professor", method)

        if @setup
            intervenants = self.get_all_elements_for_initialisation("Intervenant")
            puts "Début de l'ajout des intervenants (initialisation)"
        else
            if method == 'Post'
                intervenants = self.get_all_elements_to_post("Intervenant")
                puts "Début de l'ajout des intervenants"
            else
                intervenants = self.get_all_elements_updated_since_last_sync("Intervenant")
                puts "Début de la modification des intervenants"
            end
        end

        puts "#{intervenants.count} intervenants ont été récupérés : #{intervenants.pluck(:id, :nom)}"

        @nb_recovered_elements += intervenants.count

        nb_audited = 0

        intervenants.each do |intervenant|
            if intervenant.valid?
                body =
                {"professor":{
                    "FIRSTNAME": intervenant.prenom,
                    "LASTNAME": intervenant.nom,
                    "EMAIL": intervenant.email,
                    "API_ID": intervenant.slug
                }}

                if method == 'Post'
                    body[:professor].merge!({"dontSendCredentials": true})
                else
                    body[:professor].merge!({"ID": intervenant.edusign_id})
                end

                response = self.prepare_body_request(body).get_response

                # TODO : Voir s'il n'y a pas d'autres status que "error" ou "success"
                puts response["status"] == 'error' ?  "<strong>Erreur d'exportation de l'intervenant #{intervenant.id}, #{intervenant.nom_prenom} : #{response["message"]}</strong>" : "Exportation de l'intervenant réussie : #{intervenant.id}, #{intervenant.nom_prenom}"

                if response["status"] == 'success'
                    if method == 'Post'
                        intervenant.update_attribute('edusign_id', response["result"]["ID"])
                    end
                    nb_audited += 1
                end
            else
                puts "L'intervenant #{intervenant.id}, #{intervenant.nom} n'est pas valide, il ne peut pas être envoyé dans Edusign : #{intervenant.errors.full_messages}"
            end
        end

        puts "Exportation des intervenants terminée."
        puts "Intervenants #{method == 'Post' ? 'ajoutés' : "modifiés"} : #{nb_audited}"

        @nb_sended_elements += nb_audited
    end

    def sync_cours(method)
        self.prepare_request_with_message("https://ext.edusign.fr/v1/course", method)

        if @setup
            cours = self.get_all_elements_for_initialisation("Cour")
            puts "Début de l'ajout des cours (initialisation)"
            cours_a_supprimer = Cour.none
        else
            if method == 'Post'
                cours = self.get_all_elements_to_post("Cour").where.not(etat: ["annulé", "reporté"])
                puts "Début de l'ajout des cours"
                cours_a_supprimer = Cour.none
            else
                cours = self.get_all_elements_updated_since_last_sync("Cour")
                puts "Début de la modification des cours"
                cours_a_supprimer = cours.where(etat: ["annulé", "reporté"])
            end
        end

        # Cours à créer / modifier du côté d'Edusign
        cours_a_envoyer = cours.where(etat: ["planifié", "confirmé", "à_réserver"])

        puts "#{cours_a_envoyer.count} cours ont été récupérés : #{cours_a_envoyer.pluck(:id, :nom)}"

        @nb_recovered_elements += cours_a_envoyer.count + cours_a_supprimer.count

        nb_audited = 0

        if cours_a_envoyer
            cours_a_envoyer.each do |cour|
                if cour.formation.edusign_id
                    body =
                    {"course":{
                        "NAME": "#{cour.formation.nom} - #{cour.nom_ou_ue}" || 'Nom du cours à valider',
                        "START": cour.debut - paris_observed_offset_seconds(cour.debut),
                        "END": cour.fin - paris_observed_offset_seconds(cour.debut),
                        "PROFESSOR": Intervenant.find_by(id: cour.intervenant_id)&.edusign_id,
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

                    puts response["status"] == 'error' ?  "<strong>Erreur d'exportation du cours #{cour.id}, #{cour.nom_ou_ue} : #{response["message"]}</strong>" : "Exportation du cours #{cour.id}, #{cour.nom_ou_ue} réussie"

                    if response["status"] == 'success'
                        if method == 'Post'
                            # pas de vérification si le cour est valide, sinon le cour sera créé sur Edusign mais sans edusign_id. Ça créerait des doublons.
                            cour.update_attribute('edusign_id', response["result"]["ID"])
                        end
                        nb_audited += 1
                    end
                else
                    puts "La formation #{cour.formation.nom} n'est pas encore reliée à Edusign. Le cours #{cour.id}, #{cour.nom_ou_ue} n'est pas envoyé"
                end
            end
        end

        # Supprime les cours reportés ou annulés
        if cours_a_supprimer.any?
            puts "Début de la suppression des cours annulés ou reportés"
            puts "#{cours_a_supprimer.count} cours ont été récupérés : #{cours_a_supprimer.pluck(:id, :nom)}"

            cours_a_supprimer.each do |cour|

                if cour.edusign_id != nil
                    self.prepare_request("https://ext.edusign.fr/v1/course/#{cour.edusign_id}", "Delete")

                    cour.update_attribute('edusign_id', nil)

                    response = self.get_response

                    puts response["status"] == 'error' ?  "<strong>Erreur d'exportation du cours #{cour.id}, #{cour.nom_ou_ue} : #{response["message"]}</strong>" : "Exportation du cours #{cour.id}, #{cour.nom_ou_ue} pour la suppression réussie"

                    if response["status"] == 'success'
                        nb_audited += 1
                    end
                end
            end
        end

        puts "Exportation des cours terminée."
        puts "Cours #{method == 'Post' ? 'ajoutés' : "modifiés"} #{cours_a_supprimer.any? ? '/ supprimés' : ''}: #{nb_audited}"

        @nb_sended_elements += nb_audited
    end

    # Cet export est différent des autres exports, c'est une méthode Patch utilisé pour le changement de salle. Toutes les fonctions export ne sont plus utlisés, sauf export_cours
    def export_cours(cours_id)
        self.prepare_request_with_message("https://ext.edusign.fr/v1/course", 'Patch')

        if cours = Cour.find(cours_id)
            @nb_recovered_elements += 1

            body =
              {"course":{
                "ID": "#{cours.edusign_id}",
                "NAME": "#{cours.formation.nom} - #{cours.nom_ou_ue}" || 'Nom du cours à valider',
                "START": cours.debut - paris_observed_offset_seconds(cours.debut),
                "END": cours.fin - paris_observed_offset_seconds(cours.debut),
                "PROFESSOR": Intervenant.find_by(id: cours.intervenant_id)&.edusign_id || ENV['EDUSIGN_DEFAULT_INTERVENANT_ID'],
                "PROFESSOR_2": Intervenant.find_by(id: cours.intervenant_binome_id)&.edusign_id,
                "API_ID": cours.id,
                "NEED_STUDENTS_SIGNATURE": true,
                "CLASSROOM": cours.salle&.nom,
                "SCHOOL_GROUP": [cours.formation.edusign_id]
              }
              }

            response = self.prepare_body_request(body).get_response

            puts response["status"] == 'error' ?  "<strong>Erreur d'exportation du cours #{cours.id}, #{cours.nom_ou_ue} : #{response["message"]}</strong>" : "Modification du cours #{cours.id}, #{cours.nom_ou_ue} (id Edusign : #{cours.edusign_id}) réussie"

            if response["status"] == 'success'
                @nb_sended_elements += 1
            end
        # else
        #     response = {}
        #     response["status"] = 'error'
        #     response["message"] = "Error : Aucun cours ne correspond à cet id : #{cours_id}"
        end

        # response
    end

    def remove_deleted_and_unfollowed_cours_in_edusign
        puts "=" * 100
        puts "Préparation de la communication de l'API Edusign"

        edusign_ids = []
        deleted_cours_to_sync_ids = []

        # Récupération des cours déjà sur Edusign,
        # qui n'appartiennent plus à une formation envoyée sur Edusign,
        # qui ne doit plus être envoyé sur Edusign,
        # qui a un intervenant devenu un examen,

        request_base = Cour.where.not(edusign_id: nil)
        condition_1 = request_base.where.not(formation_id: Formation.not_archived.sent_to_edusign_ids)
        condition_2 = request_base.where(no_send_to_edusign: true)
        condition_3 = request_base.joins(:intervenant).where(intervenant: { id: Intervenant.examens_ids })

        # Récupération des ids des cours récupérés
        cours_to_remove_in_edusign_ids = condition_1.or(condition_2).pluck(:id) + condition_3.pluck(:id)

        # Récupération des cours à supprimer
        cours_unfollowed = Cour.where(id: cours_to_remove_in_edusign_ids.uniq)

        edusign_ids << cours_unfollowed.pluck(:edusign_id)

        # Récupération des cours supprimés
        deleted_cours = Audited::Audit
            .where(auditable_type: "Cour")
            .where(action: "destroy")
            .where(created_at: get_interval_of_time)

        # Pour les edusign ids des cours supprimés, on vérifie s'il existe encore sur Edusign
        deleted_cours.each do |deleted_cour|
            edusign_id = deleted_cour.audited_changes["edusign_id"]
            self.prepare_request("https://ext.edusign.fr/v1/course/#{edusign_id}", "Get")
            response = self.get_response(false)
            if response["status"] == "success" && edusign_id != nil
                edusign_ids << edusign_id
                deleted_cours_to_sync_ids << deleted_cour.auditable_id
            end
        end

        edusign_ids = edusign_ids.flatten

        puts "Début de la suppression des cours"
        puts "#{edusign_ids.count} cours ont été récupérés : #{deleted_cours_to_sync_ids}, #{cours_unfollowed.pluck(:id)}"

        @nb_recovered_elements += edusign_ids.count

        nb_audited = 0

        # Suppression des cours sur Edusign avec les edusign ids qui ont été récupérés
        edusign_ids.each do |edusign_id|
            self.prepare_request("https://ext.edusign.fr/v1/course/#{edusign_id}", "Delete")

            response = self.get_response

            puts response["status"] == 'error' ?  "<strong>Erreur lors de la suppression du cours #{edusign_id} : #{response["message"]}</strong>" : "Exportation du cours #{edusign_id} pour la suppression réussie"

            if response["status"] == 'success'
                # Suppression de l'edusign_id du cours supprimé sur Edusign
                if cour = Cour.find_by(edusign_id: edusign_id)
                    cour.update_attribute('edusign_id', nil)
                end
                nb_audited += 1
            end
        end

        puts "Cours supprimés : #{nb_audited}"

        @nb_sended_elements += nb_audited
    end

    def add_grouped_cours(cour_ids)
        cours = Cour.where(id: cour_ids)
        self.prepare_request_with_message("https://ext.edusign.fr/v1/course", "Post")
        puts "Début du groupement des cours #{cours.pluck(:id, :nom)}"

        formations_edusign_ids = Formation.where(id: cours.pluck(:formation_id)).pluck(:edusign_id)
        
        if !formations_edusign_ids.include?(nil)
            cour_template = cours.first
            intervenant = Intervenant.find_by(id: cour_template.intervenant_id)
            intervenant_binome = Intervenant.find_by(id: cour_template.intervenant_binome_id)
            
            if intervenant&.edusign_id
                if !intervenant_binome || intervenant_binome.edusign_id
                    body =
                    {"course":{
                        "NAME": "#{cour_template.nom_ou_ue}" || 'Nom du cours à valider',
                        "START": cour_template.debut - paris_observed_offset_seconds(cour_template.debut),
                        "END": cour_template.fin - paris_observed_offset_seconds(cour_template.debut),
                        "PROFESSOR": intervenant&.edusign_id,
                        "PROFESSOR_2": intervenant_binome&.edusign_id,
                        "API_ID": cour_template.id,
                        "NEED_STUDENTS_SIGNATURE": true,
                        "CLASSROOM": cour_template.salle&.nom,
                        "SCHOOL_GROUP": formations_edusign_ids
                        }
                    }
    
                    response = self.prepare_body_request(body).get_response
    
                    puts response["status"] == 'error' ?  "<strong>Erreur d'exportation : #{response["message"]}</strong>" : "Exportation des cours réussie"
                else
                    puts "L'intervenant binome #{intervenant_binome&.prenom_nom} n'est pas encore relié à Edusign. Le groupement n'est pas fait"
                end
            else
                puts "L'intervenant #{intervenant&.prenom_nom} n'est pas encore relié à Edusign. Le groupement n'est pas fait"
            end
        else
            puts "Au moins une formation n'est pas encore reliée à Edusign. Le groupement n'est pas fait"
        end

        return response
    end

    def get_etat
        puts "=" * 100
        puts "===> Nombre d'éléments récupérés : #{@nb_recovered_elements}, nombre d'éléments envoyés : #{@nb_sended_elements}, nombre d'échecs : #{self.count_failure_elements}"

        # Modification de l'etat
        if @crash
            3 # Crash
        elsif @nb_recovered_elements != 0
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

    # Récupère le timezone de Paris sur un moment donné
    def paris_observed_offset_seconds(time)
        zone = ActiveSupport::TimeZone['Paris']
        time = Time.utc(time.year, time.month, time.day, time.hour, time.min, time.sec)
        period = zone.tzinfo.period_for_utc(time)
        period.observed_utc_offset.seconds
    end

    # def export_formation(formation_id)
    #     self.prepare_request_with_message("https://ext.edusign.fr/v1/student", 'Post')

    #     if formation = Formation.not_archived.find(formation_id)
    #         @nb_recovered_elements += 1

    #         if formation.edusign_id == nil && formation.etudiants.count > 0
    #             body =
    #               {"group":{
    #                 "NAME": formation.nom,
    #                 "STUDENTS": formation.etudiants.pluck(:edusign_id).compact,
    #                 "API_ID": formation.id
    #               }}

    #             response = self.prepare_body_request(body).get_response

    #             puts response["status"] == 'error' ?  "<strong>Error : #{response["message"]}</strong>" : "Exportation de la formation #{formation.id}, #{formation.nom} réussie"

    #             if response["status"] == 'success'
    #                 formation.update_attribute('edusign_id', response["result"]["ID"])
    #                 @nb_sended_elements += 1
    #             end
    #         else
    #             message = formation.edusign_id ? "Formation déjà existante dans Edusign, #{formation.edusign_id}." : "La formation n'a pas d'étudiant."
    #             puts message

    #             response = {}
    #             response["status"] = 'error'
    #             response["message"] = message
    #         end
    #     # else
    #     #     response = {}
    #     #     response["status"] = 'error'
    #     #     response["message"] = "Error : Aucune formation ne correspond à cet id : #{formation_id}"
    #     end

    #     # response
    # end

    # def export_etudiant(etudiant_id)
    #     self.prepare_request_with_message("https://ext.edusign.fr/v1/student", 'Post')

    #     if etudiant = Etudiant.find(etudiant_id)
    #         @nb_recovered_elements += 1

    #         if etudiant.edusign_id == nil
    #             body =
    #             {"student":{
    #                 "FIRSTNAME": etudiant.prénom,
    #                 "LASTNAME": etudiant.nom,
    #                 "EMAIL": etudiant.email,
    #                 "API_ID": etudiant.id,
    #                 "GROUPS": etudiant.formation&.edusign_id
    #             }}

    #             response = self.prepare_body_request(body).get_response

    #             puts response["status"] == 'error' ?  "<strong>Error : #{response["message"]}</strong>" : "Exportation de l'étudiant #{etudiant.id}, #{etudiant.nom} réussie"

    #             if response["status"] == 'success'
    #                 etudiant.update_attribute('edusign_id', response["result"]["ID"])
    #                 @nb_sended_elements += 1
    #             end
    #         # else
    #         #     response = {}
    #         #     response["status"] = 'error'
    #         #     response["message"] = "Apprenant déjà existant sur Edusign,  #{etudiant.edusign_id}."
    #         end
    #     # else
    #     #     response = {}
    #     #     response["status"] = 'error'
    #     #     response["message"] = "Error : Aucun étudiant ne correspond à cet id : #{etudiant_id}"
    #     end
    #     #
    #     # response
    # end

    # def export_intervenant(intervenant_slug)
    #     self.prepare_request_with_message("https://ext.edusign.fr/v1/professor", 'Post')

    #     if intervenant = Intervenant.find_by(slug: intervenant_slug)
    #         @nb_recovered_elements += 1

    #         body =
    #           {"professor":{
    #             "FIRSTNAME": intervenant.prenom,
    #             "LASTNAME": intervenant.nom,
    #             "EMAIL": intervenant.email,
    #             "API_ID": intervenant.slug
    #           },
    #            "dontSendCredentials": true
    #           }

    #         response = self.prepare_body_request(body).get_response

    #         puts response["status"] == 'error' ?  "<strong>Error : #{response["message"]}</strong>" : "Exportation de l'intervenant #{intervenant.id}, #{intervenant.nom} réussie"

    #         if response["status"] == 'success'
    #             intervenant.update_attribute('edusign_id', response["result"]["ID"])
    #             @nb_sended_elements += 1
    #         end
    #     # else
    #     #     response = {}
    #     #     response["status"] = 'error'
    #     #     response["message"] = "Error : Aucun intervenant ne correspond à ce slug : #{intervenant_slug}"
    #     end

    #     # response
    # end

end