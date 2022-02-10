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

    desc "Informer des cours confirmés"
    task :informer_intervenants, [:enregistrer] => :environment do |task, args|
        # s'il y a eu des confirmations ce jours
        if Invit.with_confirmée_state.where("DATE(updated_at) = ?", Date.today).any?
            # envoyer à chaque intervenants la liste des cours confirmés
            Invit.with_confirmée_state.where("DATE(updated_at) = ?", Date.today).pluck(:intervenant_id).uniq.each do | id |
                InvitMailer.with(intervenant_id: id).informer_intervenant.deliver_now
            end
        end    
    end


end