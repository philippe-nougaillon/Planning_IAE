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
        
        # Envoyer à nouveau (relancer) toutes les invitations
        invitations.each do | invit |
            invit.relancer!
        end

        puts "-- Traitement terminé --"
        puts "#{invitations.size} invitations(s) traitée(s)"
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