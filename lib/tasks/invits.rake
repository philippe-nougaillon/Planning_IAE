namespace :invits do
    
    desc "Relancer par email"
    task :relancer, [:enregistrer] => :environment do |task, args|

        # Ne pas se lancer si week-end (samedi=6, dimanche=0)
        next if [6,0].include?(Date.today.wday)
        
        délai = 4.days

        invitations = Invit
                        .with_envoyé_state
                        .or(Invit.with_relance1_state)
                        .or(Invit.with_relance2_state)
                        .or(Invit.with_relance3_state)
                        .where("DATE(updated_at) <= ?", Date.today - délai)
                        # Les invitations de surveillance d'examen ont leur propre relance datée
                        # (tâche invits:relancer_surveillance_examens : J-15 et J-4 avant l'examen)
                        .where.not(cour_id: Cour.examens.select(:id))

        # Envoyer à nouveau (relancer) toutes les invitations
        invitations.each do | invit |
            #TODO : check à faire : la relance ne se fait probablement pas, et la mettre dans un mail_log (c.f. invits_controller.rb)
            invit.relancer!
        end

        puts "-- Traitement terminé --"
        puts "#{invitations.size} invitations(s) traitée(s)"
    end

    desc "Rappeler les surveillances d'examen (J-15 et J-4 avant la date de l'examen)"
    task :relancer_surveillance_examens, [:enregistrer] => :environment do |task, args|

        examens_ids = Intervenant.examens_ids
        next if examens_ids.blank?

        # Jalons de rappel : nombre de jours avant la date de l'examen (cour.debut)
        jalons = [15, 4]
        # États encore en attente d'une réponse du surveillant
        états_en_attente = [Invit::ENVOYE, Invit::RELANCE1, Invit::RELANCE2, Invit::RELANCE3]

        dates_cibles = jalons.map { |jours| Date.today + jours.days }

        invitations = Invit
                        .where(workflow_state: états_en_attente)
                        .joins(:cour)
                        .where(cours: { intervenant_id: examens_ids })
                        .where("DATE(cours.debut) IN (?)", dates_cibles)

        invitations.find_each do | invit |
            jours_restants = (invit.cour.debut.to_date - Date.today).to_i
            title = "[PLANNING] Rappel : proposition de surveillance d’examen(s) #{ invit.cour.formation.nom } à l’IAE Paris-Sorbonne (J-#{ jours_restants })"

            invit.relancer! if invit.can_relancer?
            mailer_response = InvitMailer.with(invit: invit, title: title).envoyer_invitation.deliver_now
            MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: invit.intervenant.email, subject: "Rappel surveillance (J-#{ jours_restants })", title: title)
        end

        puts "-- Traitement terminé --"
        puts "#{invitations.size} rappel(s) de surveillance envoyé(s)"
    end

    desc "Informer les intervenants des cours confirmés"
    task :informer_intervenants, [:enregistrer] => :environment do |task, args|
        # s'il y a eu des confirmations ce jour
        if Invit.with_confirmée_state.where("DATE(updated_at) = ?", Date.today).any?
            # envoyer à chaque intervenants la liste des cours confirmés
            Invit.with_confirmée_state.where("DATE(updated_at) = ?", Date.today).pluck(:intervenant_id).uniq.each do | id |
                InvitMailer.with(intervenant_id: id).informer_intervenant.deliver_now
            end
        end    
    end

    desc "Informer les gestionnaires des nouvelles disponibilités"
    task :informer_gestionnaires, [:enregistrer] => :environment do |task, args|
        # s'il y a eu des dispos ce jour
        @invits = Invit.where("DATE(invits.updated_at) = ?", Date.today - 1.day)
        if @invits.with_disponible_state.or(@invits.with_pas_disponible_state).any?
            # Envoyer à chaque gestionnaire
            @invits.with_disponible_state
                    .or(@invits.with_pas_disponible_state)
                    .joins(:cour, :formation)
                    .pluck('formations.user_id')
                    .uniq
                    .each do | gestionnaire_id |

                InvitMailer.with(gestionnaire_id: gestionnaire_id).informer_gestionnaire.deliver_now  
                puts "Envoyé à gestionnaire #" + gestionnaire_id.to_s
            end
        end
    end

end