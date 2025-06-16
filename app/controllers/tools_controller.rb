# ENCODING: UTF-8

class ToolsController < ApplicationController  
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  require 'capture_stdout'

  before_action :is_user_authorized

  def index
  end

  def import
  end

  def import_do
    if params[:upload]
      
      # Enregistre le fichier localement (format = Date + nom du fichier)
      filename = I18n.l(Time.now, format: :long) + ' - ' + params[:upload].original_filename
      file_with_path = Rails.root.join('public', filename)
      
      File.open(file_with_path, 'wb') do |file|
        file.write(params[:upload].read)
      end

      log = ImportLog.new(model_type: 'Cours', fichier: filename, user_id: current_user.id)

      @importes = @errors = 0 
      index = 1

      # IMPORT XLS
      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet.open file_with_path
      sheet1 = book.worksheet 0

      headers = Cour.xls_headers

      sheet1.each 1 do |row|
        index += 1

        next unless row[0]

        # MAJ cours existant ? si l'id est égal à 0 => c'est une création
        id = row[0].to_i 
        if id == 0
          cours = Cour.new
        else
          if Cour.exists?(id)
            cours = Cour.find(id)
          else
            cours = Cour.new
          end
        end

        jour_debut = row[headers.index 'Date_début']
        if jour_debut.class == Date
          jour_debut = jour_debut.day.to_s + "/" + jour_debut.month.to_s + "/" + jour_debut.year.to_s        
        end
          
        jour_fin = row[headers.index 'Date_fin']
        if jour_fin.class == Date
          jour_fin = jour_fin.day.to_s + "/" + jour_fin.month.to_s + "/" + jour_fin.year.to_s        
        end

        horaire_debut = row[headers.index 'Heure_début']
        # si Excel converti la colone heure en DateHeure, on ne prend que l'heure et minute
        if horaire_debut.class == DateTime
          horaire_debut = horaire_debut.hour.to_s + ":" + horaire_debut.minute.to_s
        end  

        horaire_fin = row[headers.index 'Heure_fin']
        if horaire_fin.class == DateTime
          horaire_fin = horaire_fin.hour.to_s + ":" + horaire_fin.minute.to_s
        end  

        intervenant = nil
        if row[headers.index 'Intervenant']
          if row[headers.index 'Intervenant'] == 'A CONFIRMER'
            intervenant = Intervenant.where(nom:'A', prenom:'CONFIRMER').first
          else  
            nom = row[headers.index 'Intervenant'].strip.split(' ').first.upcase
            prenom = row[headers.index 'Intervenant'].strip.split(' ').last
            intervenant = Intervenant.where(nom:nom, prenom:prenom).first_or_initialize
            if intervenant.new_record?
              intervenant.email = "?"
              intervenant.save if params[:save] == 'true'
            end
          end
        end

        binome = nil
        if row[headers.index 'Binôme']
          nom_binome = row[headers.index 'Binôme'].strip.split(' ').first.upcase
          prenom_binome = row[headers.index 'Binôme'].strip.split(' ').last
          binome = Intervenant.where(nom: nom_binome, prenom: prenom_binome).first_or_initialize
        end

        formation = nil
        if !params[:formation_id].blank?
          formation = Formation.find(params[:formation_id])
        elsif row[headers.index 'Formation']
          formation = Formation.find_by(nom: row[headers.index 'Formation'].strip)
        end

        elearning = (row[headers.index 'Intervenant'] == 'E-LEARNING Hors_IAE') || 
                    (row[headers.index 'E-learning?'].try(:upcase) == 'OUI')
        
        begin
          debut = Time.parse(jour_debut + " " + horaire_debut + 'UTC')
          fin   = Time.parse(jour_fin + " " +  horaire_fin + 'UTC')

          cours.debut = debut
          cours.fin = fin
          cours.duree = ((fin - debut)/3600)
          cours.intervenant = intervenant
          cours.intervenant_binome = binome
          cours.formation = formation
          cours.elearning = elearning
          cours.code_ue = row[headers.index 'UE']
          cours.nom = row[headers.index 'Intitulé']
          cours.hors_service_statutaire = true if row[headers.index 'HSS?'].try(:upcase) == 'OUI'

          msg = "COURS #{cours.new_record? ? 'NEW' : 'UPDATE'} => id:#{id} changes:#{cours.changes}"

          if cours.valid? 
            cours.save if params[:save] == 'true'
          else
            msg << " || ERREURS: " + cours.errors.messages.map{|m| "#{m.first} => #{m.last}"}.join(', ')
          end

          _etat = ( cours.valid? ? ImportLogLine.etats[:succès] : ImportLogLine.etats[:echec]) 

          cours.valid? ? @importes += 1 : @errors += 1 

        rescue StandardError => e  
          msg = "ERREUR FATALE: #{ e.message }"

          _etat = ImportLogLine.etats[:echec]
          @errors += 1 
        end

        log.import_log_lines.build(etat: _etat, num_ligne: index, message: msg)

      end

      _etat = if @errors.zero?
        ImportLog.etats[:succès] 
      else 
        if @errors < @importes 
          ImportLog.etats[:warning]
        else
          ImportLog.etats[:echec]
        end
      end   
      
      log.update(etat: _etat, nbr_lignes: @importes + @errors, lignes_importees: @importes)
      log.update(message: (params[:save] == 'true' ? "Importation" : "Simulation") )

      # log.update(message: log.message + " | Formation: #{ formation ? formation.try(:nom) : 'INCONNUE' }" )

      if @errors > 0
        log.update(message: log.message + " | #{@errors} lignes rejetées !")
      end   
      log.save
      
      flash[:notice] = "L'importation a bien été exécutée"
      redirect_to import_logs_path
    else
      flash[:alert] = "Manque le fichier source ou la formation pour pouvoir lancer l'importation !"
      redirect_to action: 'import'
    end  
  end

  def import_intervenants
  end

  def import_intervenants_do
    if params[:upload]
      
      # Enregistre le fichier localement (format = Date + nom du fichier)
      filename = I18n.l(Time.now, format: :long) + ' - ' + params[:upload].original_filename

      file_with_path = Rails.root.join('public', filename)
      File.open(file_with_path, 'wb') do |file|
        file.write(params[:upload].read)
      end

      log = ImportLog.new(model_type: 'Intervenants', fichier: filename, user_id: current_user.id)

      @importes = @errors = 0 
      index = 1

      # IMPORT XLS
      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet.open file_with_path
      sheet1 = book.worksheet 0
      headers = Intervenant.xls_headers

      sheet1.each 1 do |row|
        index += 1

        next unless row[0]

        intervenant = Intervenant
                            .where("lower(nom) = ? AND lower(prenom) = ?", 
                              row[headers.index 'Nom'].strip.downcase, 
                              row[headers.index 'Prénom'].strip.downcase)
                            .first_or_initialize

        intervenant.nom = row[headers.index 'Nom'].strip.upcase 
        intervenant.prenom = row[headers.index 'Prénom'].strip
        intervenant.email = row[headers.index 'Email']
        intervenant.linkedin_url = row[headers.index 'Linkedin_url']
        intervenant.titre1 = row[headers.index 'Titre1']
        intervenant.titre2 = row[headers.index 'Titre2']
        intervenant.status = row[headers.index 'Statut']
        intervenant.spécialité = row[headers.index 'Spécialité']
        intervenant.téléphone_fixe = row[headers.index 'Téléphone_fixe']
        intervenant.téléphone_mobile = row[headers.index 'Téléphone_mobile']
        intervenant.bureau = row[headers.index 'Bureau']

        # MAJ existant ? si l'id est égal à 0 => c'est une création
        msg = "INTERVENANT #{intervenant.new_record? ? 'NEW' : 'UPDATE'} => id:#{intervenant.id} changes:#{intervenant.changes}"

        if intervenant.valid? 
          intervenant.save if params[:save] == 'true'
        else
          msg << " || ERREURS: " + intervenant.errors.messages.map{|m| "#{m.first} => #{m.last}"}.join(',')
        end

        _etat = ( intervenant.valid? ? ImportLogLine.etats[:succès] : ImportLogLine.etats[:echec]) 
        log.import_log_lines.build(etat: _etat, num_ligne: index, message: msg)

        intervenant.valid? ? @importes += 1 : @errors += 1 
      end

      _etat = if @errors.zero?
        ImportLog.etats[:succès] 
      else 
        if @errors < @importes 
          ImportLog.etats[:warning]
        else
          ImportLog.etats[:echec]
        end
      end   
      
      log.update(etat: _etat, nbr_lignes: @importes + @errors, lignes_importees: @importes)
      log.update(message: (params[:save] == 'true' ? "Importation" : "Simulation") )

      if @errors > 0
        log.update(message: log.message + " | #{@errors} lignes rejetées !")
      end   
      log.save
      
      flash[:notice] = "L'importation a bien été exécutée"
      redirect_to import_logs_path
    else
      flash[:alert] = "Manque le fichier source pour pouvoir lancer l'importation !"
      redirect_to action: 'import_intervenants'
    end

  end

  def import_utilisateurs
  end

  def import_utilisateurs_do
    if params[:upload]

      unless params[:role].blank?
        role = params[:role]
      else
        role = nil
      end

      # Enregistre le fichier localement (format = Date + nom du fichier)
      filename = I18n.l(Time.now, format: :long) + ' - ' + params[:upload].original_filename

      file_with_path = Rails.root.join('public', filename)
      File.open(file_with_path, 'wb') do |file|
        file.write(params[:upload].read)
      end

      log = ImportLog.new(model_type: 'Users', fichier: filename, user_id: current_user.id)

      @importes = @errors = 0 
      index = 1

      # IMPORT XLS
      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet.open file_with_path
      sheet1 = book.worksheet 0
      headers = User.xls_headers

      # each(x) : où x = nombre de lignes à éviter
      sheet1.each(2) do |row|
        index += 1
        next unless row[0]

        generated_password = Devise.friendly_token.first(12)
        user = User
                  .where("lower(nom) = ? AND lower(prénom) = ?", 
                    row[headers.index 'nom'].try(:strip).try(:downcase), 
                    row[headers.index 'prénom'].try(:strip).try(:downcase)
                  )
                  .first_or_initialize

        new_record = user.new_record?
        
        user.nom = row[headers.index 'nom'].try(:strip).try(:upcase) 
        user.prénom = row[headers.index 'prénom'].try(:strip)
        user.email = row[headers.index 'email']
        user.mobile = row[headers.index 'mobile']
        user.password = generated_password if new_record
        # role = "étudiant" si tout est nil blank ou false
        user.role = role ? role : row[headers.index 'rôle'] || user.role

        # MAJ existant ? si l'id est égal à 0 => c'est une création
        msg = "USER #{new_record ? 'NEW' : 'UPDATE'} => id:#{user.id} changes:#{user.changes}"

        if user.valid? 
          if params[:save] == 'true'
            user.save
            UserMailer.welcome_email(user.id, generated_password).deliver_now if new_record
          end
          _etat = ImportLogLine.etats[:succès]
          @importes += 1
        else
          msg << " || ERREURS: " + user.errors.messages.map{|m| "#{m.first} => #{m.last}"}.join(',')
          _etat =  ImportLogLine.etats[:echec]
          @errors += 1
        end
        log.import_log_lines.build(etat: _etat, num_ligne: index, message: msg)
      end

      _etat = if @errors.zero?
        ImportLog.etats[:succès] 
      else 
        if @errors < @importes 
          ImportLog.etats[:warning]
        else
          ImportLog.etats[:echec]
        end
      end   
      
      log.update(etat: _etat, nbr_lignes: @importes + @errors, lignes_importees: @importes)
      log.update(message: (params[:save] == 'true' ? "Importation" : "Simulation") )

      if @errors > 0
        log.update(message: log.message + " | #{@errors} lignes rejetées !")
      end
      log.save
      
      flash[:notice] = "L'importation a bien été exécutée"
      redirect_to import_logs_path
    else
      flash[:alert] = "Manque le fichier source pour pouvoir lancer l'importation !"
      redirect_to action: 'import_utilisateurs'
    end 
  end

  def import_etudiants
  end

  def import_etudiants_do
    if params[:upload] 

      unless params[:formation_id].blank?
        formation_id = params[:formation_id]
        workflow_state = :étudiant
      else
        formation_id = nil
        workflow_state = :prospect
      end

      # Enregistre le fichier localement (format = Date + nom du fichier)
      filename = I18n.l(Time.now, format: :long) + ' - ' + params[:upload].original_filename

      file_with_path = Rails.root.join('public', filename)
      File.open(file_with_path, 'wb') do |file|
        file.write(params[:upload].read)
      end

      log = ImportLog.new(model_type: 'Etudiants', fichier: filename, user_id: current_user.id)

      @importes = @errors = 0 
      index = 1

      # IMPORT XLS
      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet.open file_with_path
      sheet1 = book.worksheet 0
      headers = Etudiant.xls_headers

      sheet1.each 1 do |row|
        index += 1

        next unless row[0]

        etudiant = Etudiant
                        .where("lower(nom) = ? AND lower(prénom) = ? AND lower(email) = ?", 
                          row[headers.index 'NOM'].try(:strip).try(:downcase), 
                          row[headers.index 'Prénom'].try(:strip).try(:downcase),
                          row[headers.index 'Mail'].try(:strip).try(:downcase))
                        .first_or_initialize

        etudiant.formation_id = formation_id
        etudiant.workflow_state = workflow_state
        etudiant.civilité = row[headers.index 'Civilité'].try(:strip)
        etudiant.nom = row[headers.index 'NOM'].try(:strip).try(:upcase) 
        # etudiant.nom_marital = row[headers.index 'NOM marital'].try(:strip).try(:upcase)
        etudiant.prénom = row[headers.index 'Prénom'].try(:strip)
        etudiant.email = row[headers.index 'Mail']
        etudiant.mobile = row[headers.index 'Mobile']
        etudiant.table = row[headers.index 'Table'] || 0
        # etudiant.date_de_naissance = date_de_naissance
        # etudiant.lieu_naissance = row[headers.index 'Lieu de naissance']
        # etudiant.pays_naissance = row[headers.index 'Pays de la ville de naissance'] 
        # etudiant.nationalité = row[headers.index 'Nationalité']
        # etudiant.adresse = row[headers.index 'Adresse']
        # etudiant.cp = row[headers.index 'CP']
        # etudiant.ville = row[headers.index 'Ville']
        # etudiant.dernier_ets = row[headers.index 'Dernier établmt fréquenté']
        # etudiant.dernier_diplôme = row[headers.index 'Dernier diplôme obtenu']
        # etudiant.cat_diplôme = row[headers.index 'Catégorie "Science" diplôme']
        # etudiant.num_sécu = row[headers.index 'Numéro Sécurité sociale']
        # etudiant.num_apogée = row[headers.index 'Numéro Apogée étudiant']
        # etudiant.poste_occupé = row[headers.index 'Poste occupé']
        # etudiant.nom_entreprise = row[headers.index 'Nom Entreprise']
        # etudiant.adresse_entreprise = row[headers.index 'Adresse entreprise']
        # etudiant.cp_entreprise = row[headers.index 'CP entreprise']
        # etudiant.ville_entreprise = row[headers.index 'Ville entreprise']
 
        # MAJ existant ? si l'id est égal à 0 => c'est une création
        msg = "ETUDIANT #{etudiant.new_record? ? 'NEW' : 'UPDATE'} => id:#{etudiant.id} changes:#{etudiant.changes}"

        if etudiant.valid? 
          if etudiant.new_record? && params[:notify] == '1' && params[:save] == 'true'
            etudiant.save
            # Création du compte d'accès (user) et envoi du mail de bienvenue
            user = User.new(nom: etudiant.nom, prénom: etudiant.prénom, email: etudiant.email, mobile: etudiant.mobile, password: SecureRandom.hex(10))
            if user.valid?
              user.save
              mailer_response = EtudiantMailer.welcome_student(user).deliver_now
              MailLog.create(user_id: current_user.id, message_id: mailer_response.message_id, to: etudiant.email, subject: "Nouvel accès étudiant")
            end
          else
            # Mise à jour des étudiants existants
            etudiant.save if params[:save] == 'true'
          end
        else
          msg << " || ERREURS: " + etudiant.errors.messages.map{|m| "#{m.first} => #{m.last}"}.join(',')
        end

        _etat = ( etudiant.valid? ? ImportLogLine.etats[:succès] : ImportLogLine.etats[:echec]) 
        log.import_log_lines.build(etat: _etat, num_ligne: index, message: msg)

        etudiant.valid? ? @importes += 1 : @errors += 1 
      end

      _etat = if @errors.zero?
        ImportLog.etats[:succès] 
      else 
        if @errors < @importes 
          ImportLog.etats[:warning]
        else
          ImportLog.etats[:echec]
        end
      end   
      
      log.update(etat: _etat, nbr_lignes: @importes + @errors, lignes_importees: @importes)
      log.update(message: (params[:save] == 'true' ? "Importation" : "Simulation") )
 
      if @errors > 0
        log.update(message: log.message + " | #{@errors} lignes rejetées !")
      end   
      log.save
      
      flash[:notice] = "L'importation a bien été exécutée"
      redirect_to import_logs_path
    else
      flash[:alert] = "Manque le fichier source pour pouvoir lancer l'importation !"
      redirect_to action: 'import_etudiants'
    end

  end

  def swap_intervenant
  end

  def swap_intervenant_do
    unless params[:intervenant_from_id].blank? and params[:intervenant_to_id].blank?
      
      # capture output
      @stream = capture_stdout do
        @importes = @errors = 0	

        @cours = Cour.where(intervenant_id:params[:intervenant_from_id])

        puts "#{@cours.count} cours à modifier"

        if (@cours.any? and params[:save] == 'true') 
          @cours.update_all(intervenant_id:params[:intervenant_to_id])
          puts "les cours ont été modifiés !"
        end 
        
        puts 
        puts "----------- Les modifications n'ont pas été enregistrées ! ---------------" unless params[:save] == 'true'
        puts

        puts "=" * 40
        puts "Lignes importées: #{@importes} | Lignes ignorées: #{@errors}"
        puts "=" * 40
      end

    else
      flash[:alert] = "Manque les intervenants afin de lancer la modification !"
      redirect_to action: 'swap_intervenant'
    end  

  end

  def creation_cours
  end

  def creation_cours_do
	  @start_date = Date.civil(params[:cours]["start_date(1i)"].to_i,
                         	 params[:cours]["start_date(2i)"].to_i,
                         	 params[:cours]["start_date(3i)"].to_i)

    @end_date = Date.civil(params[:cours]["end_date(1i)"].to_i,
                         	 params[:cours]["end_date(2i)"].to_i,
                           params[:cours]["end_date(3i)"].to_i)

    # Calcul le nombre de jours à traiter dans la période à traiter
    @ndays = (@end_date - @start_date).to_i + 1 
    salle_id = params[:salle_id]
    nom_cours = params[:nom]
    semaines = params[:semaines]

    @cours_créés = @erreurs = 0

    @stream = capture_stdout do
      current_date = @start_date
      # Pour chaque jour de la période à traiter
      @ndays.times do
        # test jour
        wday = current_date.wday
        ok_jours = ((params[:lundi] && wday == 1) || (params[:mardi] && wday == 2) || 
                    (params[:mercredi] && wday == 3) || (params[:jeudi] && wday == 4) || 
                    (params[:vendredi] && wday == 5) || (params[:samedi] && wday == 6))
        # test semaine 
        ok_semaines = !params.include?('semaines') || (params[:semaines] && params[:semaines].include?(current_date.cweek.to_s))
        
        cours = []

        # création du cours type
        new_cours = Cour.new(formation_id: params[:formation_id], intervenant_id: params[:intervenant_id], nom: nom_cours, code_ue: params[:code_ue], salle_id: salle_id, hors_service_statutaire: params[:hors_service_statutaire])

        # cours du matin
        if params[:am]
          c = new_cours.dup
          c.duree = 3
          c.debut = Time.parse(current_date.to_s + " 9:00 UTC")
          c.fin = eval("c.debut + #{c.duree}.hour")
          cours << c
        end  

        # cours après midi
        if params[:pm]
          c = new_cours.dup
          c.duree = 3
          c.debut = Time.parse(current_date.to_s + " 13:00 UTC")
          c.fin = eval("c.debut + #{c.duree}.hour")
          cours << c
        end

        # cours du soir
        unless params[:soir_params].blank?
          c = new_cours.dup
          case params[:soir_params]
          when '1'
            c.duree = 3
            c.debut = Time.parse(current_date.to_s + " 19:00 UTC")
          when '2'  
            c.duree = 2
            c.debut = Time.parse(current_date.to_s + " 18:15 UTC")
          when '3'  
            c.duree = 2
            c.debut = Time.parse(current_date.to_s + " 20:15 UTC")
          end
          c.fin = eval("c.debut + #{c.duree}.hour")
          cours << c
        end
 
        if params[:other]
          # calcul de la date & heure de début et de fin  
          c = new_cours.dup
          c.duree = params[:duree]
          c.debut = Time.parse(current_date.to_s + " #{params[:cours]["start_date(4i)"]}:#{params[:cours]["start_date(5i)"]} UTC")
          c.fin = eval("c.debut + #{c.duree}.hour")
          cours << c
        end

        cours.each do | new_cours |  
          if ok_jours && ok_semaines
            msg = "#{I18n.l(new_cours.debut, format: :long)}-#{I18n.l(new_cours.fin, format: :heures_log)}"
            # création du cours
            if new_cours.valid?
              new_cours.save if params[:save] == 'true'
              puts "[OK] #{msg}"
              @cours_créés += 1
            else
              puts "[KO!] #{msg} => #{new_cours.errors.full_messages.join(', ')}"
              @erreurs += 1
            end
          end
        end
        
	  		current_date = current_date + 1.day
	  	end
	  	puts
		  puts "=" * 120
	  	puts "Création termninée | #{@cours_créés} cours #{'créé'.pluralize(@cours_créés)} | #{@erreurs} #{'erreur'.pluralize(@erreurs)}"
		  puts "=" * 120
	  	puts
	  	puts "--------!-!-! Les modifications n'ont pas été enregistrées !-!-!----------" unless params[:save] == 'true'
	  end  	
  end

  def export
  end

  def export_do
    cours = Cour.includes(:formation, :intervenant, :salle, :audits).order(:debut)

    unless params[:start_date].blank? and params[:end_date].blank? 
      @start_date = Date.parse(params[:start_date])
      @end_date = Date.parse(params[:end_date])

      cours = cours.where("cours.debut BETWEEN DATE(?) AND DATE(?)", @start_date, @end_date)
    end

    unless params[:formation_id].blank?
      cours = cours.where(formation_id:params[:formation_id])
    end

    unless params[:intervenant_id].blank?
      intervenant_id = params[:intervenant_id]
      if params[:binome].present?
        cours = cours.where("intervenant_id = ? OR intervenant_binome_id = ?", intervenant_id, intervenant_id)
      else
        cours = cours.where(intervenant_id: intervenant_id)
      end
    end

    unless params[:etat].blank?
      cours = cours.where(etat:params[:etat])
    end

    unless params[:academ].blank?
      book = CoursAcademToXls.new(cours.réalisé).call
    else
      book = CoursToXls.new(cours, params[:binome].present?, true).call
    end
    file_contents = StringIO.new
    book.write file_contents # => Now file_contents contains the rendered file output
    filename = "Export_Cours.xls"
    send_data file_contents.string.force_encoding('binary'), filename: filename 
  end

  def export_intervenants
  end

  def export_intervenants_do
    intervenants = Intervenant.all

    date_debut = params[:date_debut]
    date_fin = params[:date_fin]

    if date_debut.present? && date_fin.present?
      intervenants_id = Cour.where("debut BETWEEN ? AND ?", date_debut, date_fin).pluck(:intervenant_id).uniq
    elsif date_debut.present?
      intervenants_id = Cour.where("debut > ?", date_debut).pluck(:intervenant_id).uniq
    elsif date_fin.present?
      intervenants_id = Cour.where("debut < ?", date_fin).pluck(:intervenant_id).uniq
    end

    if intervenants_id
      intervenants = intervenants.where(id: intervenants_id)
    else
      intervenants = Intervenant.all
    end

    unless params[:status].blank?
      intervenants = intervenants.where("status = ?", params[:status])
    end

    book = IntervenantsToXls.new(intervenants, date_debut, date_fin).call
    file_contents = StringIO.new
    book.write file_contents # => Now file_contents contains the rendered file output
    filename = "Export_Intervenants_#{Date.today.to_s}.xls"
    send_data file_contents.string.force_encoding('binary'), filename: filename 
  end

  def export_utilisateurs
  end

  def export_utilisateurs_do
    if params[:desactives]
      users = User.all 
    else
      users = User.kept
    end

    book = UsersToXls.new(users).call
    file_contents = StringIO.new
    book.write file_contents # => Now file_contents contains the rendered file output
    filename = "Export_Utilisateurs_#{Date.today.to_s}.xls"
    send_data file_contents.string.force_encoding('binary'), filename: filename 
  end

  def export_etudiants
  end

  def export_etudiants_do
    etudiants = Etudiant.all

    unless params[:formation_id].blank?
      etudiants = etudiants.where(formation_id: params[:formation_id])
    end

    book = EtudiantsToXls.new(etudiants).call
    file_contents = StringIO.new
    book.write file_contents # => Now file_contents contains the rendered file output
    filename = "Export_Etudiants_#{Date.today.to_s}.xls"
    send_data file_contents.string.force_encoding('binary'), filename: filename 
  end

  def export_formations
  end

  def export_formations_do
    formations = Formation.all

    formations = formations.where(archive: false) unless params[:archive]

    book = FormationsToXls.new(formations).call
    file_contents = StringIO.new
    book.write file_contents # => Now file_contents contains the rendered file output
    filename = "Export_Formations_#{Date.today.to_s}.xls"
    send_data file_contents.string.force_encoding('binary'), filename: filename 
  end

  def export_vacations
    @activités = Vacation.pluck(:titre).uniq.compact_blank.sort
    @intervenants = Intervenant.all

    if params[:status].present?
      @intervenants = @intervenants.where(status: params[:status])
    end
  end

  def export_vacations_do
    vacations = Vacation.all
    @intervenants = Intervenant.all

    if params[:status].present?
      vacations = vacations.joins(:intervenant).where("intervenants.status = ?", params[:status])
      @intervenants = @intervenants.where("status = ?", params[:status])
    end

    if params[:intervenant_id].present?
      vacations = vacations.where(intervenant_id: params[:intervenant_id])
    end

    if params[:formation_id].present?
      vacations = vacations.where(formation_id: params[:formation_id])
    end

    if params[:activité].present?
      vacations = vacations.where(titre: params[:activité])
    end

    if params[:commit] == "Exporter"
      book = VacationsToXls.new(vacations.includes(:formation, :intervenant)).call
      file_contents = StringIO.new
      book.write file_contents # => Now file_contents contains the rendered file output
      filename = "Export_Vacations_#{Date.today.to_s}.xls"
      send_data file_contents.string.force_encoding('binary'), filename: filename
    else
      redirect_to tools_export_vacations_path(status: params[:status], formation_id: params[:formation_id], activité: params[:activité])
    end
  end

  def etats_services

    @intervenants ||= []

    unless params[:start_date].blank? || params[:end_date].blank?
      @start_date = params[:start_date]
      @end_date = params[:end_date]
    else
      params[:start_date] ||= Date.today.at_beginning_of_month.last_month
      params[:end_date]   ||= Date.today.last_month.at_end_of_month
    end

    unless params[:status].blank?
      # Peupler la liste des intervenants ayant eu des cours en principal ou binome
      @cours = Cour
                .where(etat: Cour.etats.values_at(:confirmé, :réalisé))
                .where("debut between ? and ?", @start_date, @end_date)

      ids = @cours.distinct(:intervenant_id).pluck(:intervenant_id)
      ids << @cours.distinct(:intervenant_binome_id).pluck(:intervenant_binome_id)

      # Ajouter les vacataires
      ids << Vacation
                .where("date between ? and ?", @start_date, @end_date)
                .distinct(:intervenant_id)
                .pluck(:intervenant_id)

      # Ajouter les responsables

      ids << Responsabilite
                .where("debut between ? and ?", @start_date, @end_date)
                .distinct(:intervenant_id)
                .pluck(:intervenant_id)

      @intervenants = Intervenant.where(id: ids.flatten).where(status: params[:status])
      @intervenants_for_select = @intervenants
    end 

    unless params[:intervenant_id].blank? 
      @intervenants = Intervenant.where(id: params[:intervenant_id])
    end

    @cumul_hetd = @cumul_vacations = @cumul_resps = 0

    respond_to do |format|
      format.html

      format.xls do
        book = CoursEtatsServicesToXls.new(@cours, @intervenants, @start_date, @end_date).call
        file_contents = StringIO.new
        book.write file_contents # => Now file_contents contains the rendered file output
        filename = "Export_Cours.xls"
        send_data file_contents.string.force_encoding('binary'), filename: filename 
      end

      format.pdf do
        filename = "Etats_de_services_#{Date.today.to_s}"
        pdf = ExportPdf.new
        pdf.export_etats_de_services(@cours, @intervenants, @start_date, @end_date)

        send_data pdf.render,
            filename: filename.concat('.pdf'),
            type: 'application/pdf',
            disposition: 'inline'	

        # response.headers['Content-Disposition'] = 'attachment; filename="' + filename + '.pdf"'
        # render pdf: filename, :layout => 'pdf.html'
      end

    end
  end

  def export_etat_liquidatif_collectif
    params[:start_date] ||= Date.today.at_beginning_of_month.last_month
    params[:end_date]   ||= Date.today.last_month.at_end_of_month
  end

  def export_etat_liquidatif_collectif_do
    start_date = params[:start_date]
    end_date = params[:end_date]

    if params[:group_by] == 'intervenant'
      book = EtatLiquidatifCollectifIntervenantToXls.new(start_date, end_date, params[:status], params[:cours], params[:vacations], params[:responsabilites]).call
      filename = "Export_Etat_liquidatif_collectif_intervenant.xls"
    else
      book = EtatLiquidatifCollectifFormationToXls.new(start_date, end_date, params[:status], params[:cours], params[:vacations], params[:responsabilites]).call
      filename = "Export_Etat_liquidatif_collectif_formation.xls"
    end

    file_contents = StringIO.new
    book.write file_contents # => Now file_contents contains the rendered file output
    send_data file_contents.string.force_encoding('binary'), filename: filename
  end

  def audits
    @audits = Audited::Audit.order("id DESC")
    @types  = Audited::Audit.pluck(:auditable_type).uniq.sort
    @actions= %w[update create destroy]
    
    if params[:start_date].present? && params[:end_date].present? 
      @audits = @audits.where("created_at BETWEEN (?) AND (?)", params[:start_date], params[:end_date])
    end

    unless params[:type].blank?
      @audits = @audits.where(auditable_type: params[:type])
    end

    unless params[:action_name].blank?
      @audits = @audits.where(action: params[:action_name])
    end

    unless params[:role].blank?
      @audits = @audits.where(user_id: User.where(role: params[:role]))
    end

    unless params[:search].blank?
      @audits = @audits.where("audited_changes ILIKE ?", "%#{params[:search]}%")
    end

    unless params[:chgt_salle].blank?
      audit_chgt_salle_id = @audits.where("audited_changes like '%salle_id%'").map {|audit|
        audit.audited_changes['salle_id'] != nil ? audit.id : nil
      }.compact
      @audits = @audits.where(id: audit_chgt_salle_id) 
    end

    unless params[:id].blank?
      # @audits = @audits.where(auditable_id: params[:id])
      @audits = @audits.where(id: params[:id])
    end

    @audits = @audits.includes(:user).paginate(page: params[:page], per_page: 20)
  end

  def taux_occupation_jours
  end

  def taux_occupation_jours_do
    unless params[:start_date].blank? and params[:end_date].blank?
      @start_date = params[:start_date]
      @end_date = params[:end_date]
    else
      flash[:alert] = "Il manque les dates..."
      redirect_to tools_taux_occupation_jours_path
      return
    end

    # Calcul du taux d'occupation
    #

    # salles concernées
    salles_dispo = Salle.salles_de_cours.count
    salles_dispo_samedi = Salle.salles_de_cours_du_samedi.count
    
    # amplitude 
    @nb_heures_journée = Salle.nb_heures_journée
    @nb_heures_soirée = Salle.nb_heures_soirée

    # nombre d'heures salles semaine
    heures_dispo_salles = [salles_dispo * @nb_heures_journée, salles_dispo_samedi * @nb_heures_soirée] 

    # nombre d'heures salles samedi
    heures_dispo_salles_samedi = [salles_dispo_samedi * @nb_heures_journée, salles_dispo_samedi * @nb_heures_soirée] 

    @nbr_jours = @total_jour = @total_soir = 0


    @results = []
    # pour chaque jour entre la date de début et la date de fin
    (@start_date.to_date..@end_date.to_date).each do |d|



      # on ne compte pas le dimanche ni les jours de fermetures
      if d.to_date.wday > 0 && !Fermeture.find_by(date:d.to_date)
        # cumul les heures de cours du jour et du soir
        nombre_heures_cours = [Cour.cumul_heures(d).first, Cour.cumul_heures(d).last]

        # calcul du taux d'occupation  
        if d.to_date.wday == 6 # le samedi, on ne comtpe que le batiment D
          taux_occupation = [(nombre_heures_cours.first * 100 / heures_dispo_salles_samedi.first),
                              (nombre_heures_cours.last * 100 / heures_dispo_salles_samedi.last)]
          @total_jour += taux_occupation.first
        else  
          taux_occupation = [(nombre_heures_cours.first * 100 / heures_dispo_salles.first), 
                              (nombre_heures_cours.last * 100 / heures_dispo_salles.last)]
          @total_jour += taux_occupation.first
          @total_soir += taux_occupation.last
        end  
        @nbr_jours += 1

        @results << [l(d.to_date, format: :long), taux_occupation.first.to_i, taux_occupation.last.to_i]
      end
    end   
  end

  def taux_occupation_salles
  end

  def taux_occupation_salles_do
    unless params[:start_date].blank? and params[:end_date].blank?
      @start_date = params[:start_date]
      @end_date = params[:end_date]
    else
      flash[:alert] = "Il manque les dates..."
      redirect_to tools_taux_occupation_salles_path
      return
    end

    # Calcul du taux d'occupation par salles
    #
    
    # amplitude 
    @nb_heures_journée = Salle.nb_heures_journée
    @nb_heures_soirée = Salle.nb_heures_soirée

    # nombre de jours dans la période
    @nbr_jours = 0
    # nombre d'heures de disponibilité des salles 
    @nbr_heures_dispo_salle = 0
    # fait le cumul des jours et des heures de dispo salle
    (@start_date.to_date..@end_date.to_date).each do |d|
      # on ne compte pas le dimanche ni les jours de fermetures
      next if Fermeture.find_by(date:d.to_date)
      case d.to_date.wday 
          when 0    # dimanche
          when 1..5 # jours de la semaine 
            @nbr_jours += 1
            @nbr_heures_dispo_salle += (@nb_heures_journée + @nb_heures_soirée)
          when 6   # samedi
            @nbr_jours += 1
            @nbr_heures_dispo_salle += @nb_heures_journée
      end
    end 

    @results = {}
    Cour.where("debut between DATE(?) AND DATE(?) AND salle_id IS NOT NULL", @start_date, @end_date).each do | c |
      if Salle.salles_de_cours.include?(c.salle)
        salle = c.salle.nom
        if @results[salle]
          @results[salle] += c.duree.to_f
        else
          @results[salle] = c.duree.to_f
        end
      end
    end
  end

  def nouvelle_saison

    @years ||= ['2021/2022','2022/2023','2023/2024','2024/2025', '2025/2026']

    unless params[:saison].blank?
      @formations = Formation.where(hors_catalogue:false)
                             .where("nom like ?", "%#{params[:saison]}%")
      
      case params[:saison]
      when @years[0]
        @date_debut = Date.parse('2021-09-02')
        @date_fin = Date.parse('2022-07-08')
      when @years[1]
        @date_debut = Date.parse('2022-09-02')
        @date_fin = Date.parse('2023-07-15')
      else
        annee_debut = params[:saison].split('/').first
        annee_fin = params[:saison].split('/').last
        @date_debut = Date.parse(annee_debut + '-08-30')
        @date_fin = Date.parse(annee_fin + '-07-15')
      end
    end

    unless params[:formation_id].blank?
      @formation_id = params[:formation_id]
    end

    if (@date_debut and @date_fin) and @formation_id
      @jours = (@date_debut..@date_fin).select{|j| j.wday == 1}
    end

  end

  def nouvelle_saison_create
    # Créer des créneaux vides sur toutes une année pour une formation
    # Permet de faire des réservations au nom de l'intervenant 'A CONFIRMER'

    if Intervenant.exists?(445)
      _intervenant = Intervenant.find(445) # A CONFIRMER
      _date_debut = Date.parse(params[:date_debut])
      _date_fin = Date.parse(params[:date_fin])
      _formation = Formation.find(params[:formation_id])
      _salle_id = params[:salle_id]
      _save = params[:save]
      _semaines = params[:semaine].try(:keys)
      _jours = []
      @errors = []
      @ids_ok = []

      if _semaines
        (_date_debut.._date_fin).each do |j|
          if _semaines.include?(j.cweek.to_s)
            wday = j.wday
            ok_jours = ((params[:lundi] && wday == 1) || (params[:mardi] && wday == 2) || 
                        (params[:mercredi] && wday == 3) || (params[:jeudi] && wday == 4) || 
                        (params[:vendredi] && wday == 5) || (params[:samedi] && wday == 6))
            # Si on est sur un jour coché, on essaye de créer le cours
            if ok_jours
              _jours << j

              # créer le cours du matin
              _retval = création_cours('9:00 UTC', _formation, j, _intervenant, _salle_id, _save)
              # si la création ne fonctionne pas
              if _retval.is_a?(Array)
                # on essaye dans la salle
                _retval = création_cours('9:00 UTC', _formation, j, _intervenant, nil, _save)
                # si ça ne fonctionne toujours pas, alors c'est une erreur
                @errors << _retval if _retval.is_a?(Array)
              end
              @ids_ok << _retval if _retval.is_a?(Integer)
                
              # créer le cours du soir
              _retval = création_cours('13:00 UTC', _formation, j, _intervenant, _salle_id, _save)
              if _retval.is_a?(Array)
                # on essaye dans la salle
                _retval = création_cours('13:00 UTC', _formation, j, _intervenant, nil, _save)
                # si ça ne fonctionne toujours pas, alors c'est une erreur
                @errors << _retval if _retval.is_a?(Array)
              end

              @ids_ok << _retval if _retval.is_a?(Integer)
            end
          end  
        end
      end

      if @errors.count > 0
        flash[:alert] = "#{ @errors.count } erreurs empêchent la création de cours !"
      end 

      flash[:notice] = "#{ @ids_ok.count } cours créés"
    else
      flash[:alert] = "L'intervenant générique 'A CONFIRMER' (445) doit exister !"
    end

  end

  def création_cours(heure, formation, jour, intervenant, salle, save)

    new_cours = Cour.new(formation: formation, intervenant: intervenant, salle_id: salle)

    new_cours.debut = Time.parse(jour.to_s + ' ' + heure)
    new_cours.duree = 3
    new_cours.fin = eval("new_cours.debut + #{new_cours.duree}.hour")

    if new_cours.valid?
      if save == 'true'
        new_cours.save 
        _retval = new_cours.id
      else
        _retval = 0
      end
    else
      _retval = [new_cours.debut, new_cours.errors.messages] 
    end
  
    return _retval
  end

  def notifier_intervenants
  end

  def notifier_intervenants_do
    require 'rake'

    Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
    Rails.application.load_tasks # providing your application name is 'sample'
      
    # capture output
    @stdout_stream = capture_stdout do
      Rake::Task['cours:envoyer_liste_cours'].reenable # in case you're going to invoke the same task second time.
      Rake::Task['cours:envoyer_liste_cours'].invoke(params[:draft].present?)
    end
  end  

  def audit_cours
    # Afficher les cours 'planifiés' 
    # entre deux dates
    # créés par un utilisateur autre que Thierry.D (#41)
    
    params[:start_date] ||= Date.today
    params[:end_date] ||= Date.today + 6.months
    params[:tri] ||= 'date_cours'
    #params[:tri] ||= 'date_création'

    unless params[:start_date].blank? && params[:end_date].blank? 
      @date_début = params[:start_date]
      @date_fin = params[:end_date]
    end

    # ids des cours créés par utilisateur autre que Thierry.D (#41)
    id_cours = Audited::Audit.where(auditable_type: 'Cour').where.not(user_id: 41).pluck(:auditable_id).uniq

    # vérifie que la date de début de cours est dans la période observée
    @cours = Cour.where("id IN (?)", id_cours)
                 .planifié
                 .where("cours.debut BETWEEN ? AND ?", @date_début, @date_fin)

    # change l'ordre de tri
    unless params[:tri].blank?
      if params[:tri] == 'date_création'
        @cours = @cours.order(created_at: :desc)
      else
        @cours = @cours.order(:debut)
      end
    end
                  
  end

  def liste_surveillants_examens

    if params[:start_date].blank? || params[:end_date].blank?
      params[:start_date] ||= Date.today.at_beginning_of_month.last_month
      params[:end_date]   ||= Date.today.last_month.at_end_of_month
    end

    @start_date = params[:start_date]
    @end_date = params[:end_date]
    surveillant = params[:surveillant]
    @cumuls = {}
    @examens = Cour
                  .where("intervenant_id IN (:surveillants) OR intervenant_binome_id IN (:surveillants)", {surveillants: [169, 1166, 522, 1314]} )
                  .where("commentaires like '%[%'")
                  .where("debut between ? and ?", @start_date, @end_date.to_date + 1.day)
                  .includes(:formation)
                  .order(:debut)

    respond_to do |format|
      format.html

      format.pdf do
        filename = "Vacations_administratives_#{ surveillant }_du_#{ @start_date }_au_#{ @end_date }"
        pdf = ExportPdf.new
        pdf.export_vacations_administratives(@examens, @start_date, @end_date, surveillant)

        send_data pdf.render,
                  filename: filename.concat('.pdf'),
                  type: 'application/pdf',
                  disposition: 'inline'	
      end
    end

  end

  def liste_surveillants_examens_v2

    if params[:start_date].blank? || params[:end_date].blank?
      params[:start_date] ||= Date.today.at_beginning_of_month.last_month
      params[:end_date]   ||= Date.today.last_month.at_end_of_month
    end

    @start_date = params[:start_date]
    @end_date = params[:end_date]
    surveillant = params[:surveillant]
    @cumuls = {}
    @examens = Cour
                  .where("intervenant_id IN (:surveillants) OR intervenant_binome_id IN (:surveillants)", {surveillants: [169, 1166, 522, 1314]} )
                  .joins(:options).where(options: {catégorie: :surveillance})
                  .where("options.description LIKE '%[%'")
                  .where("debut BETWEEN ? AND ?", @start_date, @end_date.to_date + 1.day)
                  .includes(:formation)
                  .order(:debut)

    respond_to do |format|
      format.html

      format.pdf do
        filename = "Vacations_administratives_#{ surveillant }_du_#{ @start_date }_au_#{ @end_date }"
        pdf = ExportPdf.new
        pdf.export_vacations_administratives_v2(@examens, @start_date, @end_date, surveillant)

        send_data pdf.render,
                  filename: filename.concat('.pdf'),
                  type: 'application/pdf',
                  disposition: 'inline'	
      end
    end

  end

  def rechercher

    if !params[:search].blank? && params[:commit] =='Go'
      @results = PgSearch.multisearch("%#{ params[:search] }%").reorder(updated_at: :desc)
      unless params[:search_cours]
        @results = @results.where.not(searchable_type: 'Cour')
      end
      unless params[:search_formations]
        @results = @results.where.not(searchable_type: 'Formation')
      end
      unless params[:search_ue]
        @results = @results.where.not(searchable_type: 'Unite')
      end
      unless params[:search_intervenants]
        @results = @results.where.not(searchable_type: 'Intervenant')
      end
      unless params[:search_etudiants]
        @results = @results.where.not(searchable_type: 'Etudiant')
      end
      unless params[:search_users]
        @results = @results.where.not(searchable_type: 'User')
      end
      unless params[:search_mail_logs]
        @results = @results.where.not(searchable_type: 'MailLog')
      end

      @results = @results.paginate(page: params[:page])
    else
      params[:search_cours] ||= '1'
      params[:search_formations] ||= '1'
      params[:search_ue] ||= '1'
      params[:search_intervenants] ||= '1'
      params[:search_etudiants] ||= '1'
      params[:search_users] ||= '1'
      params[:search_mail_logs] ||= '1'
    end
  end

  def rappel_des_cours
    @intervenants = Intervenant.where(doublon: false)
    @formations = Formation.all
  end

  def rappel_des_cours_do
    unless params[:intervenant_id].blank? && params[:formation_id].blank? && (params[:du].blank? && params[:au].blank?)
      @envoi_log = EnvoiLog.new
      @envoi_log.date_prochain = DateTime.now

      if not params[:intervenant_id].blank?
        @envoi_log.cible = "Intervenant"
        @envoi_log.cible_id = params[:intervenant_id]
      elsif not params[:formation_id].blank?
        @envoi_log.cible = "Formation"
        @envoi_log.cible_id = params[:formation_id]
      else
        @envoi_log.cible = "Tous les intervenants"
      end

      unless params[:du].blank? && params[:au].blank?
        @envoi_log.date_début = params[:du]
        @envoi_log.date_fin = params[:au]
      end

      @envoi_log.workflow_state = "prêt"
      @envoi_log.save

      redirect_to envoi_logs_path, notice: "Job ajouté à la file d'attente"
    end
  end

  def rappel_des_examens
    @examens = Intervenant.where(id: [169, 522, 1166])
    @formations = Formation.all
  end

  def rappel_des_examens_do
    unless params[:intervenant_id].blank? && params[:formation_id].blank? && (params[:du].blank? && params[:au].blank?)
      @envoi_log = EnvoiLog.new
      @envoi_log.date_prochain = DateTime.now

      @envoi_log.cible = "Examen"
      if params[:examen_id].present?
        @envoi_log.cible_id = params[:examen_id]
      end

      unless params[:du].blank? && params[:au].blank?
        @envoi_log.date_début = params[:du]
        @envoi_log.date_fin = params[:au]
      end

      @envoi_log.workflow_state = "prêt"
      @envoi_log.save

      redirect_to envoi_logs_path, notice: "Job ajouté à la file d'attente"
    end
  end

  def acces_intervenants
    params[:paginate] ||= 'pages'
    authorized_intervenants_email = User.intervenant.pluck(:email).map(&:downcase)
    @intervenants = Intervenant.where.not("LOWER(intervenants.email) IN (?)", authorized_intervenants_email)

    unless params[:search].blank?
      @intervenants = @intervenants.where("LOWER(nom) like :search or LOWER(prenom) like :search or LOWER(email) like :search", {search: "%#{params[:search]}%".downcase})
    end

    unless params[:status].blank?
      @intervenants = @intervenants.where("status = ?", params[:status])
    end

    if params[:paginate] == 'pages'
      @intervenants = @intervenants.paginate(page: params[:page], per_page: 10)
    end
  end

  def acces_intervenants_do
    errors = 0
    valids = 0

    intervenants = Intervenant.where(id: params[:intervenants_id].keys)
    intervenants.each do |intervenant|
      new_password = SecureRandom.hex(10)
      # Création du compte d'accès (user) et envoi du mail de bienvenue
      user = User.new(role: "intervenant", nom: intervenant.nom, prénom: intervenant.prenom, email: intervenant.email, mobile: intervenant.téléphone_mobile, password: new_password)
      if user.valid?
        user.save
        valids += 1
        mailer_response = IntervenantMailer.with(user: user, password: new_password).welcome_intervenant.deliver_now
        MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: user.email, subject: "Nouvel accès intervenant")
      else
        errors += 1
      end
    end
    if errors >= 1
      redirect_to tools_acces_intervenants_path, alert: "Nombre d'erreurs : #{errors}. Nombre de comptes créés : #{valids}"
    else
      redirect_to tools_acces_intervenants_path, notice: "#{valids} accès intervenants créés"
    end
  end

  def commandes
    if params[:archive].present?
      @commandes = Cour.commandes_archivées
    else
      @commandes = Cour.commandes
    end

    if params[:search_cmd].present?
      @commandes = @commandes.where("cours.commentaires ILIKE ?", "%#{params[:search_cmd]}%")
    end
  end

  def commande_fait
    commande = Cour.find(params[:commande_id])
    commande.commentaires.concat("\r\n\r\n")
    commande.commentaires.concat("Fait le #{l DateTime.now, format: :short}, #{current_user.nom_et_prénom}")
    commande.save

    redirect_to request.referrer, notice: "Commande traitée avec succès"
  end

  def commandes_v2
    if params[:archive].present?
      @commandes = Cour.commandes_archivées_v2
    else
      @commandes = Cour.commandes_v2
    end

    if params[:search_cmd].present?
      @commandes = @commandes.where("options.description ILIKE ?", "%#{params[:search_cmd]}%")
    end
  end

  def commande_fait_v2
    commande = Cour.find(params[:commande_id]).options.commande.first
    commande.fait = true
    commande.description.concat("\r\n\r\n")
    commande.description.concat("Fait le #{l DateTime.now, format: :short}, #{current_user.nom_et_prénom}")
    commande.save

    redirect_to request.referrer, notice: "Commande traitée avec succès"
  end

  def edusign
    @intervenants = Intervenant.all
    @formations = Formation.all
    @étudiants = Etudiant.ordered
  end

  def edusign_do
    return unless params[:intervenant_id].present? || params[:etudiant_id].present? || params[:formation_id].present?

    request = Edusign.new

    if params[:intervenant_id].present?
      response = request.export_intervenant(params[:intervenant_id])
      record_type = "l'intervenant"
    elsif params[:formation_id].present?
      response = request.export_formation(params[:formation_id])
      record_type = "la formation (Groupe)"
    elsif params[:etudiant_id].present?
      response = request.export_etudiant(params[:etudiant_id])
      record_type = "l'étudiant (Apprenant)"
    end

    if response["status"] == 'error'
        flash[:alert] = "Erreur Edusign : #{response["message"]}"
    else
        flash[:notice] = "Création avec succès de #{record_type} sur Edusign ! ID sur Edusign : #{response["result"]["ID"]}"
    end

    redirect_to tools_edusign_path

  end

  def synchronisation_edusign
  end

  def synchronisation_edusign_do
    etat = 0

    # capture output
    @stream = capture_stdout do
      request = Edusign.new
      puts "C'est parti !"

      request.call
      
      etat = request.get_etat
    end


    EdusignLog.create(modele_type: "Auto sync", message: @stream, user_id: current_user.id, etat: etat)
  end

  private

  # def ajout_etudiants

  #   request = Edusign.new("https://ext.edusign.fr/v1/student", 'Post')

  #   etudiants_added = request.get_all_element_created_today(Etudiant).where(edusign_id: nil)

  #   etudiants_added.each do |etudiant|
  #     body =
  #       {"student":{
  #         "FIRSTNAME": etudiant.prénom,
  #         "LASTNAME": etudiant.nom,
  #         "EMAIL": etudiant.email,
  #         "API_ID": etudiant.id,
  #       }}

  #     response = request.prepare_body_request(body).get_response

  #     if response["status"] == 'error'
  #       flash[:alert] = response["message"]
  #       break
  #     end

  #     etudiant.edusign_id = response["result"]["ID"]

  #     etudiant.save
  #   end

  #   ajout_formations(etudiants)

  # end

  # def modification_etudiants

  #   request = Edusign.new("https://ext.edusign.fr/v1/student", 'Patch')

  #   etudiants_updated = request.get_all_element_updated_today(Etudiant).where("created_at != updated_at")

  #   etudiants_updated.each do |etudiant|
  #     body =
  #       {"student":{
  #         "ID": etudiant.edusign_id,
  #         "FIRSTNAME": etudiant.prénom,
  #         "LASTNAME": etudiant.nom,
  #         "EMAIL": etudiant.email,
  #         "GROUPS": Formation.find(etudiant.formation_id).edusign_id
  #       }}

  #     response = request.prepare_body_request(body).get_response

  #     if response["status"] == 'error'
  #       flash[:alert] = response["message"]
  #       break
  #     end
  #   end
  # end

  # def ajout_formations(etudiants)

  #   request = Edusign.new("https://ext.edusign.fr/v1/group", 'Post')

  #   formations = Formation.where(id: etudiants.pluck(:formation_id).uniq).where(edusign_id: nil)

  #   formations.each do |formation|

  #     body =
  #       {"group":{
  #         "NAME": formation.nom,
  #         "STUDENTS": formation.etudiants.pluck(:edusign_id).compact
  #       }}

  #     response = request.prepare_body_request(body).get_response

  #     if response["status"] == 'error'
  #       flash[:alert] += response["message"]
  #       break
  #     end

  #     formation.edusign_id = response["result"]["ID"]

  #     formation.save
  #   end
  # end

  # def modification_formations
  #   request = Edusign.new("https://ext.edusign.fr/v1/group/", 'Patch')

  #   formations_updated = request.get_all_element_updated_today(Formation)

  #   formations_updated.each do |formation|
  #     body =
  #       {"group":{
  #         "ID": formation.edusign_id,
  #         "NAME": formation.nom,
  #         "STUDENTS": formation.etudiants.pluck(:edusign_id).compact
  #       }}

  #     response = request.prepare_body_request(body).get_response

  #     if response["status"] == 'error'
  #       flash[:alert] = response["message"]
  #       break
  #     end
  #   end
  # end

  # def ajout_intervenants

  #   request = Edusign.new("https://ext.edusign.fr/v1/professor", 'Post')

  #   intervenants_added = request.get_all_element_created_today(Intervenant)

  #   intervenants_added.each do |intervenant|
  #     body =
  #       {"professor":{
  #         "FIRSTNAME": intervenant.prenom,
  #         "LASTNAME": intervenant.nom,
  #         "EMAIL": intervenant.email,
  #         "API_ID": intervenant.id,
  #         "dontSendCredentials": true
  #       }}

  #     response = request.prepare_body_request(body).get_response

  #     if response["status"] == 'error'
  #       flash[:alert] = response["message"]
  #       break
  #     end

  #     intervenant.edusign_id = response["result"]["ID"]

  #     intervenant.save
  #   end
  # end

  # def modification_intervenants

  #   request = Edusign.new("https://ext.edusign.fr/v1/professor", 'Patch')

  #   intervenants_updated = request.get_all_element_updated_today(Intervenant)

  #   intervenants_updated.each do |intervenant|
  #     body =
  #       {"professor":{
  #         "ID": intervenant.edusign_id,
  #         "FIRSTNAME": intervenant.prenom,
  #         "LASTNAME": intervenant.nom,
  #         "EMAIL": intervenant.email
  #       }}

  #     response = request.prepare_body_request(body).get_response

  #     if response["status"] == 'error'
  #       flash[:alert] = response["message"]
  #       break
  #     end
  #   end
  # end

  # def ajout_cours

  #   request = Edusign.new("https://ext.edusign.fr/v1/course", 'Post')

  #   cours_added = request.get_all_element_created_today(Cour)

  #   cours_added.each do |cours|
  #     body =
  #       {"course":{
  #         "NAME": cours.nom.presence || 'sans nom',
  #         "START": cours.debut - 1.hour,
  #         "END": cours.fin - 1.hour,
  #         "PROFESSOR": Intervenant.find(cours.intervenant_id).edusign_id,
  #         "API_ID": cours.id,
  #         "NEED_STUDENTS_SIGNATURE": true,
  #         "SCHOOL_GROUP": [cours.formation.edusign_id]
  #       }}

  #     response = request.prepare_body_request(body).get_response

  #     if response["status"] == 'error'
  #       flash[:alert] = response["message"]
  #       break
  #     end

  #     cours.edusign_id = response["result"]["ID"]

  #     cours.save
  #   end
  # end

  # def modification_cours
  #   request = Edusign.new("https://ext.edusign.fr/v1/course", 'Patch')

  #   cours_updated = request.get_all_element_updated_today(Cour)

  #   cours_updated.each do |cours|
  #     body =
  #       {"course":{
  #         "ID": cours.edusign_id,
  #         "NAME": cours.nom,
  #         "START": cours.debut - 1.hour,
  #         "END": cours.fin - 1.hour,
  #         "PROFESSOR": Intervenant.find(cours.intervenant_id).edusign_id,
  #         "NEED_STUDENTS_SIGNATURE": true,
  #         "editSurveys": false,
  #         "SCHOOL_GROUP": [cours.formation.edusign_id]
  #       }}

  #     response = request.prepare_body_request(body).get_response

  #     if response["status"] == 'error'
  #       flash[:alert] = response["message"]
  #       break
  #     end
  #   end
  # end

    def is_user_authorized
      authorize :tool
    end
end
