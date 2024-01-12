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
  task :envoyer_liste_cours, [:envoi_log_id, :test] => :environment do |task, args|

    envoi_specs = EnvoiLog.find(args.envoi_log_id)
    puts "Cible: #{args.test == 'true' ? 'Testeurs' : envoi_specs.cible}"

    if envoi_specs.date_début && envoi_specs.date_fin
      start_day = envoi_specs.date_début
      end_day   = envoi_specs.date_fin
    else
      start_day = Date.today.beginning_of_month + 1.month
      end_day   = start_day.end_of_month + 1.day 
    end

    puts "Notification des prochains cours sur la période du #{I18n.l start_day} au #{I18n.l end_day}"
    puts '- ' * 50

    envoyes = 0

    case envoi_specs.cible
    when 'Intervenant'
      intervenants = Intervenant.where(id: envoi_specs.cible_id)
    when 'Formation'
      intervenants = Formation.find(envoi_specs.cible_id).intervenants
    else
      intervenants = Intervenant.where(doublon: false)
    end

    intervenants.each do | intervenant |
      cours = Cour.where("debut BETWEEN (?) AND (?)", start_day, end_day)
                  .where(etat: Cour.etats.values_at(:planifié, :confirmé))
                  .where("intervenant_id = ? OR intervenant_binome_id = ?", intervenant.id, intervenant.id)
                  .order(:debut)

      if envoi_specs.cible == 'Formation'
        cours = cours.where(formation_id: envoi_specs.cible_id) 
      end

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

        envoyes += 1 if envoyer_liste_cours_a_intervenant(start_day, end_day, intervenant, cours, liste_des_gestionnaires, envoi_specs.id, args.test) 

        # Mettre à jour les infos du job
        envoi_specs.update(mail_count: envoyes)

        # puts "Pause !"
        # # faire une grande pause de 40 secondes pour ne pas dépasser la limite de 100mails/heure imposée par la période de probation
        # sleep 37

        # Faire une petite pause pour ne pas être pris pour un spammeur
        sleep 5

        puts "#-" * 50
      end 
    end

    puts "* #{envoyes} mail(s) envoyé(s) *"

    # Mettre à jour les infos du job
    envoi_specs.update(workflow_state: "envoyé", date_exécution: DateTime.now ,mail_count: envoyes)
  end

  desc "Envoyer le lien des sessions des intervenants"
  task envoyer_sessions_intervenants: :environment do
    now = ApplicationController.helpers.time_in_paris_selon_la_saison

    cours = Cour.where(formation_id: [258, 599, 671, 683, 687]).confirmé.where("DATE(debut) = ?", Date.today)
    # cours = Cour.confirmé.where("DATE(debut) = ?", Date.today)
    cours.each do |cour|
      if now > cour.debut + 30.minute && now < cour.debut + 40.minute
        intervenant = cour.intervenant
        presence = Presence.find_or_create_by(cour_id: cour.id, intervenant_id: intervenant.id, code_ue: cour.code_ue)
        mailer_response = IntervenantMailer.mes_sessions(intervenant, presence.slug, cour.formation.try(:user).try(:email)).deliver_now
        MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: intervenant.email, subject: "Validation présences")

        puts "email envoyé à #{intervenant.nom_prenom}, email : #{intervenant.email}"
        puts "slug : #{presence.slug}"
      end
    end
  end

  def envoyer_liste_cours_a_intervenant(debut, fin, intervenant, cours, gestionnaires, envoi_log_id, test)
    if !intervenant.email.blank? && intervenant.email != '?'
      puts "OK => Planning envoyé à: #{intervenant.email}"

      mailer_response = IntervenantMailer
                                        .notifier_cours(debut, fin, intervenant, cours, gestionnaires, envoi_log_id, test)
                                        .deliver_now

      MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: intervenant.email, subject: "Rappel des cours")

      return true
    else
      puts "!KO => Manque l'adresse email de '#{intervenant.nom_prenom}' (= #{intervenant.email})" 
      return false
    end
  end

end
