# ENCODING: UTF-8

namespace :cours do

  desc "TODO"
  task update_duree: :environment do
	  Cour.where(duree:0).each do |cours|
	  	cours.update_attributes(duree:(cours.fin - cours.debut) / 60 / 60)
  	end
  end

  desc "Passer les cours J - 1 en état Confirmé vers l'état Réalisé"
  task update_etat_realises: :environment do
      Cour.where("DATE(debut)=?", Date.today - 1.day)
          .where(etat: Cour.etats[:confirmé])
          .update_all(etat: Cour.etats[:réalisé])
  end

  desc "Envoyer la liste des cours aux intervenants" 
  task :envoyer_liste_cours, [:envoi_log_id] => :environment do |task, args|

    envoi_specs = EnvoiLog.find(args.envoi_log_id)
    puts "Cible: #{envoi_specs.cible}"

    start_day = Date.today.beginning_of_month + 1.month
    end_day   = start_day.end_of_month + 1.day 

    puts "Notification des prochains cours sur la période du #{I18n.l start_day} au #{I18n.l end_day}"
    puts '- ' * 50

    envoyes = 0

    if envoi_specs.cible == 'Testeurs'
      # id des intervenants tests
      intervenants = Intervenant.where("UPPER(nom) LIKE '%NOUGAILLON%' OR UPPER(nom) LIKE '%FITSCH%'")
      puts "Intervenants TEST = #{ intervenants.pluck(:nom) }" 
    else
      intervenants = Intervenant.all
    end

    intervenants.each do | intervenant |
      cours = Cour.where("debut BETWEEN (?) AND (?)", start_day, end_day)
                  .where(etat: Cour.etats.values_at(:planifié, :confirmé))
                  .where.not(intervenant_id: 445) # Intervenant fictif 'A CONFIRMER' dont on ne veut pas ici
                  .where("intervenant_id = ? OR intervenant_binome_id = ?", intervenant.id, intervenant.id)

      if cours.any?
        puts "#{intervenant.nom_prenom} (##{intervenant.id})" 
                      
        liste_des_cours_a_envoyer = []
        liste_des_gestionnaires = {}

        cours.each do |c|
          intitulé_cours = "#{I18n.l(c.debut.to_date, format: :day)} #{I18n.l(c.debut.to_date)} #{I18n.l(c.debut, format: :heures_min)}-#{I18n.l(c.fin, format: :heures_min)} #{c.try(:formation).try(:nom)}/#{c.nom_ou_ue}"
          liste_des_cours_a_envoyer << intitulé_cours
          if c.formation
            liste_des_gestionnaires[c.formation.nom] = (c.formation.courriel ? c.formation.courriel : c.formation.try(:user).try(:email))
          end
        end
        puts "#{liste_des_cours_a_envoyer.count} cours à envoyer: #{liste_des_cours_a_envoyer}"  

        liste_des_gestionnaires.each do | formation, gest |
          puts "Gestionnaire #{formation} = #{gest}"
        end

        envoyes += 1 if envoyer_liste_cours_a_intervenant(args.draft, start_day, end_day, intervenant, cours, liste_des_gestionnaires, envoi_specs.id) 

        puts "#-" * 50
      end 
    end

    puts "* #{envoyes} mail(s) envoyé(s) *"

  end

  def envoyer_liste_cours_a_intervenant(draft, debut, fin, intervenant, cours, gestionnaires, envoi_log_id)
    if !intervenant.email.blank? && intervenant.email != '?'
      puts "OK => Planning envoyé à: #{intervenant.email}"

      IntervenantMailer
          .notifier_cours(debut, fin, intervenant, cours, gestionnaires, envoi_log_id)
          .deliver_now

      return true
    else
      puts "!KO => Manque l'adresse email de '#{intervenant.nom_prenom}' (= #{intervenant.email})" 

      return false
    end
  end

end
