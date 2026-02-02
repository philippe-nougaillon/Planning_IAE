# ENCODING: UTF-8

class CoursController < ApplicationController
  include ApplicationHelper
  include CoursHelper

  skip_before_action :authenticate_user!, only: %i[ index index_slide mes_sessions_intervenant signature_intervenant signature_intervenant_do ]
  before_action :set_cour, only: [:show, :edit, :update, :destroy, :delete_attachment]
  before_action :is_user_authorized, except: [:show, :edit, :update, :destroy, :signature_etudiant, :signature_etudiant_do]

  layout :define_layout

  def define_layout
    if params[:action] == 'index_slide'
      'slide'
    else
      'application'
    end
  end

  # GET /cours
  # GET /cours.json
  def index
    session[:view] ||= 'list'
    session[:filter] ||= 'upcoming'
    session[:paginate] ||= 'pages'
    params[:paginate] = 'pages' if disabled_paginate?(params)

    if current_user && params.keys.count == 2
      if (current_user.enseignant? || (current_user.intervenant? && !current_user.partenaire_qse?))
        if intervenant = Intervenant.where("LOWER(intervenants.email) = ?", current_user.email.downcase).first
          params[:intervenant_id] = intervenant.id
          params[:intervenant] = intervenant.nom + " " + intervenant.prenom
        end
      elsif current_user.étudiant?
        if etudiant = Etudiant.find_by("LOWER(etudiants.email) = ?", current_user.email.downcase)
          if formation = etudiant.formation
            params[:formation_id] = formation.id
            params[:formation] = formation.nom
          end
        end
      end
    end

    if params[:commit] && params[:commit][0..2] == 'RàZ'
      session[:formation] = params[:formation] = nil
      session[:intervenant] = params[:intervenant] = nil
      session[:intervenant_id] = params[:intervenant_id] = nil
      session[:intervenant_nom] = params[:intervenant_nom] = nil
      session[:ue] = params[:ue] = nil
      session[:week_number] = params[:week_number] = nil
      session[:start_date] = params[:start_date] = Date.today.to_s
      session[:start_date_mobile] = params[:start_date_mobile] = DateTime.now.at_beginning_of_day.to_s
      session[:etat] = params[:etat] = nil
      session[:view] = params[:view] = 'list'
      session[:filter] = params[:filter] = 'upcoming'
      session[:paginate] = params[:paginate] = 'pages'
    end

    params[:start_date] ||= session[:start_date]
    params[:formation] ||= session[:formation]
    params[:intervenant] ||= session[:intervenant]
    params[:intervenant_nom] ||= session[:intervenant_nom]
    params[:ue] ||= session[:ue]
    params[:etat] ||= session[:etat]
    params[:view] ||= session[:view]
    params[:filter] ||= session[:filter]
    params[:paginate] ||= session[:paginate]

    @cours = Cour.order(:debut)

    # Si N° de semaine, afficher le premier jour de la semaine choisie, sinon date du jour
    unless params[:week_number].blank?
      raw = params[:week_number].to_s.strip
      begin
        if raw.match?(/^\d{4}-W\d{1,2}$/)
          # Format "2025-W38"
          year, week = raw.split('-')
        elsif raw.match?(/^\d{1,2}$/)
          # Format "38"
          year = Date.today.year
          week = raw
        else
          raise ArgumentError, "Format de semaine invalide"
        end

        week_number = week.gsub('W', '').to_i
        @date = Date.commercial(year.to_i, week_number, 1)
      rescue ArgumentError => e
        @date = Date.today.beginning_of_week
      end
    else
      if params[:start_date].present?
        begin
          @date = Date.parse(params[:start_date])
        rescue
          @date = Date.today
        end
      else
        @date = Date.today
      end
    end
    params[:start_date] = @date.to_s

    if request.variant.include?(:phone)
      if params[:start_date_mobile].present?
        selected_datetime = DateTime.parse(params[:start_date_mobile])
      else
        params[:start_date_mobile] = l(DateTime.now.at_beginning_of_day, format: :sql).to_s
      end
    end
    case params[:view]
      when 'calendar_rooms'
        _date = Date.parse(params[:start_date]).beginning_of_week(start_day = :monday)
        @cours = @cours.where(debut: (_date .. _date + 7.day))
        params[:calendar_rooms_starts_at] = _date
      when 'calendar_week'
        _date = Date.parse(params[:start_date]).beginning_of_week(start_day = :monday)
        @cours = @cours.where("cours.debut BETWEEN DATE(?) AND DATE(?)", _date, _date + 7.day)
        params[:calendar_week_starts_at] = _date
      when 'calendar_month'
        _date = Date.parse(params[:start_date]).beginning_of_month
        @cours = @cours.where("cours.debut BETWEEN DATE(?) AND DATE(?)", _date, _date + 1.month)
      else
        # Pour éviter le crash au moment du rendu d'un partial inconnu
        params[:view] = 'list'
        @alert = Alert.visibles.first
        unless params[:filter] == 'all'
          if params[:week_number].present?
            @cours = @cours.where("cours.debut BETWEEN DATE(?) AND DATE(?)", @date, @date + 7.day)
          elsif selected_datetime
            @cours = @cours.where("cours.debut >= ?", l(selected_datetime, format: :sql))
          else
            @cours = @cours.where("cours.debut >= DATE(?)", @date)
          end
        else
          @date = nil
        end
    end

    unless params[:formation_id].blank?
      params[:formation] = Formation.not_archived.find(params[:formation_id]).nom.rstrip
    end

    unless params[:formation].blank?
      formation_id = Formation.not_archived.find_by(nom:params[:formation].rstrip)
      @cours = @cours.where(formation_id:formation_id)
    end

    unless params[:intervenant].blank? || !user_signed_in?
      intervenant = params[:intervenant].strip
      intervenant_id = Intervenant.find_by(nom: intervenant.split(' ').first, prenom: intervenant.split(' ').last.rstrip)
      @cours = @cours.where("intervenant_id = ? OR intervenant_binome_id = ?", intervenant_id, intervenant_id)
    end

    unless params[:intervenant_id].blank?
      intervenant_id = params[:intervenant_id]
      @cours = @cours.where("intervenant_id = ? OR intervenant_binome_id = ?", intervenant_id, intervenant_id)
    end

    unless params[:etat].blank?
      @cours = @cours.where(etat:params[:etat])
    end

    unless params[:salle_id].blank?
      @cours = @cours.where(salle_id:params[:salle_id])
    end

    unless params[:ue].blank?
      @cours = @cours.where(code_ue: params[:ue])
    end

    unless params[:ids].blank?
      # affiche les cours d'un ID donné
      @cours = Cour.where(id:params[:ids]).order(:debut)
    end

    unless params[:intervenant_nom].blank?
      if intervenants_id = Intervenant.where("nom LIKE ?", "%#{ params[:intervenant_nom].strip.upcase }%").pluck(:id)
        @cours = @cours
                    .where(intervenant_id: intervenants_id)
                    .or(@cours.where(intervenant_binome_id: intervenants_id))
      else
        # ne rien afficher si l'intervenant n'existe pas
        @cours = Cour.where(id: 0)
      end
    end

    @all_cours = @cours
    @cours = @cours.includes(:formation, :intervenant, :salle)

    if (params[:view] == 'list' and (params[:paginate] == 'pages' and request.variant.include?(:desktop) ))
      @cours = @cours.paginate(page: clean_page(params[:page]))
    end

    if request.variant.include?(:phone)
      @cours = @cours.paginate(page: params[:page])
      @formations = Formation.not_archived.ordered.select(:nom).where(hors_catalogue: false).pluck(:nom)
    end

    if params[:view] == "calendar_rooms"
      @cours = @cours.where(etat: Cour.etats.values_at(:à_réserver, :planifié, :confirmé, :annulé, :reporté, :réalisé))
    end

    #@week_numbers =  ((Date.today.cweek.to_s..'52').to_a << ('1'..(Date.today.cweek - 1).to_s).to_a).flatten

    session[:formation] = params[:formation]
    session[:intervenant] = params[:intervenant]
    session[:intervenant_nom] = params[:intervenant_nom]
    session[:ue] = params[:ue]
    session[:start_date] = params[:start_date]
    session[:etat] = params[:etat]
    session[:view] = params[:view]
    session[:filter] = params[:filter]
    session[:paginate] = params[:paginate]

    respond_to do |format|
      format.html do
        if request.variant.include?(:phone)
          @cours = @cours.where("fin > ?", DateTime.now)
        end
      end

      format.xls do
        book = CoursToXls.new(@cours, !params[:intervenant]).call
        file_contents = StringIO.new
        book.write file_contents # => Now file_contents contains the rendered file output
        filename = "Export_Cours.xls"
        send_data file_contents.string.force_encoding('binary'), filename: filename
      end

      format.ics do
        @calendar = Cour.generate_ical(@cours)
        filename = "Export_iCalendar_#{Date.today.to_s}"
        response.headers['Content-Disposition'] = 'attachment; filename="' + filename + '.ics"'
        headers['Content-Type'] = "text/calendar; charset=UTF-8"
        render plain: @calendar.to_ical
      end

      format.pdf do
        filename = "Export_Planning_#{Date.today.to_s}"
        pdf = ExportPdf.new
        pdf.export_liste_des_cours(@cours, false)

        send_data pdf.render,
            filename: filename.concat('.pdf'),
            type: 'application/pdf',
            disposition: 'inline'
      end
    end
  end

  def index_slide
    # page courante
    session[:page_slide] ||= 0

    @now = ApplicationController.helpers.time_in_paris_selon_la_saison

    if params[:planning_date]
      # Afficher tous les cours du jours
      begin
        @planning_date = DateTime.parse(params[:planning_date])
      rescue
        @planning_date = Date.today
      end
      # si date du jour, on ajoute l'heure qu'il est
      @planning_date = @now if @planning_date == Date.today
    else
      # afficher tous les cours du jour
      @planning_date = @now
    end

    @tous_les_cours = Cour.where(etat: Cour.etats.values_at(:planifié, :confirmé))
                          .where("DATE(fin) = ? AND fin > ?", @planning_date.to_date, @planning_date.to_formatted_s(:db))
                          .reorder(:debut, :fin)
                          .pluck(:id)

    @cours_count = @tous_les_cours.size

    unless @cours_count.zero?
      # effectuer une rotation de x pages de 7 cours

      per_page = 7
      @max_page_slide = (@cours_count / per_page) - 1
      @max_page_slide += 1 unless @cours_count.%(per_page).zero?

      @current_page_slide = session[:page_slide].to_i

      if @current_page_slide < @max_page_slide
        session[:page_slide] = @current_page_slide + 1
      else
        session[:page_slide] = 0
      end

      @cours_ids = @tous_les_cours.slice(per_page * @current_page_slide, per_page)
      @les_cours_à_afficher = Cour.includes(:formation, :intervenant, :salle).where(id: @cours_ids).reorder(:debut, :fin)

      @alert = Alert.visibles.first
    else
      # Affiche un papier peint si pas de cours à afficher
      require 'net/http'
      begin
        url = "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=fr-FR"
        uri = URI(url)
        response = Net::HTTP.get(uri)
        json = JSON.parse(response)
        @image = json["images"][0]["url"]
      rescue => e
        Rails.logger.error("Erreur chargement image Bing : #{e.message}")
        @image = nil
      end
    end
  end

  def action
    unless params[:cours_id].blank? or params[:action_name].blank?
      @action_ids = params[:cours_id].keys

      if params[:action_name] == 'Changer de salle'
        # Afficher les salles disponibles
        @salles_dispos = Salle.pluck(:nom)
        @action_ids.each do |id|
          cours = Cour.find(id)
          salles = []
          Salle.all.each do |s|
            cours.salle = s
            salles << s.nom if cours.valid?
          end
          @salles_dispos = @salles_dispos & salles
        end
      elsif params[:action_name] == 'Intervertir'
        # Tester si la durée de deux cours n'est pas égale
        # pour prévenir l'utilisateur qu'il y a danger de chevauchement
        durées = []
        @action_ids.each do |id|
          durées << Cour.find(id).duree.to_f
        end
        if durées.first != durées.last
          @intervertir_alerte = "Attention, les deux cours n'ont pas la même durée, il y a un risque de chevauchement..."
        end
      end

      @cours = Cour
                  .unscoped
                  .includes(:intervenant, :formation, :salle, :audits)
                  .where(id: @action_ids)
                  .order(:debut)

      if ["Générer Pochette Examen PDF", "Convocation étudiants PDF"].include?(params[:action_name])
        @sujet = @cours.first.sujet
      end

    else
      redirect_to cours_path, alert:'Veuillez choisir des cours et une action à appliquer !'
    end
  end

  def action_do
    action_name = params[:action_name]

    @cours = Cour
                .unscoped
                .where(id: params[:cours_id].keys)
                .order(:debut)

    case action_name
      when 'Changer de salle'
        salle = !params[:salle_id].blank? ? Salle.find(params[:salle_id]) : nil
        @cours.each do |c|
          c.salle = salle
          flash[:alert] = c.errors.messages unless c.save
        end

      when "Changer d'état"
        @cours.each do |c|
          c.etat = params[:etat].to_i
          c.save
          ## envoyer de mail par défaut (after_validation:true) sauf si envoyer email pas coché
          #c.save(validate:params[:email].present?)

          # notifier les étudiants des changements ?
          if params[:notifier]
            c.formation.etudiants.each do | etudiant |
              NotifierEtudiantsJob.perform_later(etudiant, c, current_user.id)
            end
          end
        end

      when "Changer de date"
        unless params[:new_date].blank?
          new_date = params[:new_date].to_date
        end
        unless params[:add_n_days].blank?
          add_n_days = params[:add_n_days].to_i
        end

        @cours.each do |c|
          if add_n_days.present?
            new_date = c.debut + add_n_days.days
          end
          if new_date.present?
            c.debut = c.debut.change(year: new_date.year, month: new_date.month, day: new_date.day)
            c.fin = c.fin.change(year: new_date.year, month: new_date.month, day: new_date.day)
          end
          if add_n_days.present? || new_date.present?
            unless c.save
              flash[:alert] = c.errors.messages
            end
          else
            flash[:alert] = "Aucun cours mis à jour"
          end
        end

      when "Changer d'intervenant"
        @cours.each do |c|
          c.intervenant_id = params[:intervenant_id].to_i
          c.save
        end

      when 'Inviter'
        invits_créées = 0
        if (params[:invits_en_cours].present? && params[:confirmation] == 'yes') || !params[:invits_en_cours].present?
          invit = params[:invit]
          (0..3).each do |i|
            intervenant_id = invit[:intervenant].values.to_a[i]
            unless intervenant_id.blank?
              @cours.each do |cour|
                cour.invits.create!(user_id: current_user.id,
                                    intervenant_id: intervenant_id.to_i,
                                    msg: params[:message_invitation],
                                    ue: invit[:ue].values.to_a[i],
                                    nom: invit[:nom].values.to_a[i])
                invits_créées += 1
              end

              # ATTENTION : Invit.first ne sera plus correct si le default_scope est modifié. Peut-être que ce n'a sera plus correct en mettant ce code dans un job
              title = "[PLANNING] Proposition de créneaux pour placer vos cours #{ Invit.first.cour.formation.nom } à l’IAE Paris-Sorbonne"
              mailer_response = InvitMailer.with(invit: Invit.first, title: title).envoyer_invitation.deliver_now
              # Pareil ici, Invit.first ne sera plus correct si le default_scope change
              MailLog.create(user_id: current_user.id, message_id:mailer_response.message_id, to:Invit.first.intervenant.email, subject: "Invitation", title: title)
            end
          end
        end
        if invits_créées > 0
          @message_complémentaire = "#{ invits_créées } invitation.s créée.s avec succès"
        else
          flash[:alert] = "Action annulée"
        end

      when 'Intervertir'
        # il faut 2 cours
        if params[:cours_id].keys.count == 2
          # TODO: dans une transaction, ça serait plus sûr !
          cours_A = Cour.find(params[:cours_id].keys.first)
          cours_B = Cour.find(params[:cours_id].keys.last)
          if params[:intervertir_intervenants]
            # Intervertit les sujets si les cours sont des examens
            # sujet_A = Sujet.find_by(cour_id: cours_A.id)
            # sujet_B = Sujet.find_by(cour_id: cours_B.id)

            # if cours_A.examen? && sujet_A && cours_B.examen? && sujet_B
            #   sujet_A.update_columns(cour_id: cours_B.id)
            #   sujet_B.update_columns(cour_id: cours_A.id)

            # elsif cours_A.examen? && sujet_A
            #   sujet_A.update_columns(cour_id: cours_B.id)

            # elsif cours_B.examen? && sujet_B
            #   sujet_B.update_columns(cour_id: cours_A.id)
            # end

            # Intervertit les deux intervenants
            intervenant_A = cours_A.intervenant_id
            intervenant_B = cours_B.intervenant_id

            cours_A.intervenant_id = intervenant_B
            cours_B.intervenant_id = intervenant_A
          end

          if params[:intervertir_binomes]
            intervenant_A = cours_A.intervenant_binome_id
            intervenant_B = cours_B.intervenant_binome_id

            cours_A.intervenant_binome_id = intervenant_B
            cours_B.intervenant_binome_id = intervenant_A
          end

          if params[:intervertir_intitulé]
            intitulé_A = cours_A.nom
            intitulé_B = cours_B.nom

            cours_A.nom = intitulé_B
            cours_B.nom = intitulé_A
          end

          if params[:intervertir_ue]
            code_ue_A = cours_A.code_ue
            code_ue_B = cours_B.code_ue

            cours_A.code_ue = code_ue_B
            cours_B.code_ue = code_ue_A
          end

          if params[:intervertir_salles]
            salle_A = cours_A.salle_id
            salle_B = cours_B.salle_id

            cours_A.salle_id = salle_B
            cours_B.salle_id = salle_A
          end

          # "validate: false" pour éviter de faire les vérifications de chevauchements et autres problèmes entre cours A et B.
          cours_A.save(validate: false)
          cours_B.save(validate: false)
        else
          flash[:alert] = "Il faut deux cours à intervertir ! Opération annulée"
        end

      when "Supprimer"
        if (params[:invits_en_cours].present? && params[:confirmation] == 'yes') || !params[:invits_en_cours].present?
          if !params[:delete].blank?
            @cours.each do |c|
              if policy(c).destroy?
                c.destroy
              else
                flash[:alert] = "Vous ne pouvez pas supprimer ce cours (##{c.id}) ! Opération annulée"
                next
              end
            end
          else
            flash[:alert] = "Suppression annulée"
          end
        else
          flash[:alert] = "Suppression annulée"
        end
      when "Exporter vers Excel"
        request.format = 'xls'

      when "Exporter vers iCalendar"
        @calendar = Cour.generate_ical(@cours)
        request.format = 'ics'

      when "Exporter en PDF", "Générer Feuille émargement PDF", "Générer Feuille émargement présences signées PDF", "Générer Pochette Examen PDF"
        request.format = 'pdf'

      when 'Convocation étudiants PDF'
        if @cours.count == 1 && @cours.first.examen?
          étudiants = Etudiant.where(id: etudiants_selected_ids)
          if étudiants.any?
            étudiants.each do |étudiant|
              pdf = ExportPdf.new
              pdf.convocation(@cours.first, étudiant, params[:papier], params[:calculatrice], params[:ordi_tablette], params[:téléphone], params[:dictionnaire], @cours.first.sujet&.commentaires)
              title = "Convocation #{@cours.first.type_examen} - #{@cours.first.nom_ou_ue}"
              mailer_response = EtudiantMailer.convocation(étudiant, pdf, @cours.first, title).deliver_now
              MailLog.create(subject: "Convocation UE##{@cours.first.code_ue}", user_id: current_user.id, message_id: mailer_response.message_id, to: étudiant.email, title: title)
            end
          else
            flash[:alert] = "Aucun étudiant n'a été sélectionné, il ne s'est rien passé"
          end
        else
          flash[:alert] = 'Il y a plusieurs cours sélectionnés ou le cours n\'est pas un examen'
        end
      when "Regrouper sur une seule Feuille de présence Edusign"
        etat = 3
        edusign_log = EdusignLog.create(modele_type: 4, message: "", user_id: current_user.id, etat: etat)
        
        begin
          response = nil
          # capture output
          stream = capture_stdout do
            request = Edusign.new
            response = request.add_grouped_cours(@cours.pluck(:id))
            etat = request.get_etat
          end

          edusign_log.update(message: stream, etat: etat)

          if response && response["status"] == 'success'
            # Pas de update_all pour éviter l'empêchement de sauvegare à cause du bypass
            @cours.each do |cour|
              cour.update_attribute('no_send_to_edusign', true)
            end
          else
            flash[:alert] = "Le groupement n'a pas pu s'effectuer, veuillez réessayer"
          end

        rescue => e
          error_message = "Erreur: #{e.full_message}"
          edusign_log.update(message: error_message, etat: 3)
          flash[:alert] = error_message
        end
    end

    filename = "Export_Planning_#{Date.today.to_s}"

    respond_to do |format|
      format.html do
        unless flash[:alert]
          flash[:notice] = "Action '#{action_name}' appliquée à #{params.permit![:cours_id].keys.size} cours. #{ @message_complémentaire if @message_complémentaire }"
        end
        redirect_to cours_path
      end

      format.csv do
        response.headers['Content-Disposition'] = 'attachment; filename="' + filename + '.csv"'
        render "cours/action_do.csv.erb"
      end

      format.xls do
        book = CoursToXls.new(@cours, !params[:intervenant]).call
        file_contents = StringIO.new
        book.write file_contents # => Now file_contents contains the rendered file output
        filename = "Export_Cours.xls"
        send_data file_contents.string.force_encoding('binary'), filename: filename
      end

      format.ics do
        response.headers['Content-Disposition'] = 'attachment; filename="' + filename + '.ics"'
        headers['Content-Type'] = "text/calendar; charset=UTF-8"
        render plain: @calendar.to_ical
      end

      format.pdf do
        case action_name
        when "Exporter en PDF"
          pdf = ExportPdf.new
          pdf.export_liste_des_cours(@cours, true)

          send_data pdf.render,
          filename: filename.concat('.pdf'),
            type: 'application/pdf',
            disposition: 'inline'
        when "Générer Feuille émargement PDF"
          filename = "Feuille_émargement_#{ Date.today }.pdf"
          pdf = ExportPdf.new
          pdf.generate_feuille_emargement(@cours, params[:etudiants_id].try(:keys), params[:table])

          send_data pdf.render, filename: filename, type: 'application/pdf'
        when "Générer Feuille émargement présences signées PDF"
          filename = "Feuille_émargement_signée#{ Date.today }.pdf"
          pdf = ExportPdf.new
          pdf.generate_feuille_emargement_signée(@cours)

          send_data pdf.render, filename: filename, type: 'application/pdf'
        when "Générer Pochette Examen PDF"
            etudiants_ids = etudiants_selected_ids
          if etudiants_ids.any?
            filename = "Pochette_Examen_#{ Date.today }.pdf"
            pdf = ExportPdf.new
            pdf.pochette_examen(@cours, etudiants_ids.count, params[:papier], params[:calculatrice], params[:ordi_tablette], params[:téléphone], params[:dictionnaire])

            send_data pdf.render, filename: filename, type: 'application/pdf'
          else 
            redirect_to cours_path, alert: "Aucun étudiant sélectionné, rien n'a été fait"
          end
        end
      end

    end
  end

  # GET /cours/1
  # GET /cours/1.json
  def show
    authorize @cour
  end

  # GET /cours/new
  def new
    @cour = Cour.new
    @formations = Formation.not_archived.ordered
    @salles = Salle.all

    if current_user.partenaire_qse?
      @formations = @formations.partenaire_qse
      @salles = @salles.where(nom: ["ICP 1", "ICP 2"])
    end

    unless params[:formation].blank?
      @cour.formation_id = Formation.not_archived.find_by(nom:params[:formation])&.id
    end

    unless params[:intervenant].blank?
      intervenant = params[:intervenant].strip
      intervenant_id = Intervenant.find_by(nom:intervenant.split(' ').first, prenom:intervenant.split(' ').last.rstrip)
      @cour.intervenant_id = intervenant_id
    end

    @cour.formation_id = params[:formation_id] if params[:formation_id]
    @cour.intervenant_id = params[:intervenant_id] if params[:intervenant_id]
    @cour.debut = params[:debut] if params[:debut]
    @cour.ue = params[:ue]
    @cour.salle_id = params[:salle_id]
    @cour.etat = params[:etat].to_i
    @cour.nom = params[:nom]
    if params[:heure]
      @cour.debut = Time.zone.parse("#{params[:debut]} #{params[:heure]}:00").to_s
    end
  end

  # GET /cours/1/edit
  def edit
    authorize @cour
    @formations = Formation.ordered
    @salles = Salle.all

    if current_user.partenaire_qse?
      @formations = @formations.partenaire_qse
      @salles = @salles.where(nom: ["ICP 1", "ICP 2"])
    end
  end

  # POST /cours
  # POST /cours.json
  def create
    @cour = Cour.new(cour_params)

    respond_to do |format|
      if @cour.valid? && @cour.save
        format.html do
          if params[:create_and_add]
            redirect_to new_cour_path(debut:@cour.debut, fin:@cour.fin,
                        formation_id:@cour.formation_id, intervenant_id:@cour.intervenant_id, ue:@cour.ue, salle_id:@cour.salle_id, nom:@cour.nom),
                        notice: 'Cours ajouté avec succès.'
          else
            if params[:from] == 'occupation'
              redirect_to occupation_salles_path, notice: "Cours ##{@cour.id} ajouté avec succès."
            else
              redirect_to cours_path, notice: "Cours ##{@cour.id} ajouté avec succès."
            end
          end
        end
        format.json { render :show, status: :created, location: @cour }
      else
        format.html do
          @formations = Formation.ordered
          @salles = Salle.all

          if current_user.partenaire_qse?
            @formations = @formations.partenaire_qse
            @salles = @salles.where(nom: ["ICP 1", "ICP 2"])
          end
          render :new
        end
        format.json { render json: @cour.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cours/1
  # PATCH/PUT /cours/1.json
  def update
    authorize @cour
    respond_to do |format|
      if @cour.update(cour_params)
        format.html do
          # notifier les étudiants des changements ?
          if params[:notifier]
            @cour.formation.etudiants.each do | etudiant |
              NotifierEtudiantsJob.perform_later(etudiant, @cour, current_user.id)
            end
          end

          # notifier l'accueil s'il y a un bypass
          if @cour.commentaires.include?("BYPASS=#{@cour.id}")
            title = "[PLANNING IAE Paris] BYPASS utilisé !"
            mailer_response = AccueilMailer.notifier_cours_bypass(@cour, current_user.email, title).deliver_now
            MailLog.create(user_id: current_user.id, message_id: mailer_response.message_id, to: "accueil@iae.pantheonsorbonne.fr", subject: "BYPASS", title: title)
          end

          # repartir à la page où a eu lieu la demande de modification
          if params[:from] == 'planning_salles'
            redirect_to cours_path(view:"calendar_rooms", start_date:@cour.debut)
          else
            if params[:from] == 'occupation'
              redirect_to occupation_salles_path, notice: "Cours ##{@cour.id} ajouté avec succès."
            else
              redirect_to cours_path, notice: 'Cours modifié avec succès.'
            end
          end
        end
        format.json { render :show, status: :ok, location: @cour }
      else
        format.html do
          @formations = Formation.ordered
          @salles = Salle.all

          if current_user.partenaire_qse?
            @formations = @formations.partenaire_qse
            @salles = @salles.where(nom: ["ICP 1", "ICP 2"])
          end
          render :edit, params
        end
        format.json { render json: @cour.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cours/1
  # DELETE /cours/1.json
  def destroy
    authorize @cour

    @cour.destroy
    respond_to do |format|
      format.html { redirect_to cours_path, notice: 'Cours supprimé.' }
      format.json { head :no_content }
    end
  end

  def mes_sessions_etudiant
    @etudiant = Etudiant.find_by("LOWER(etudiants.email) = ?", current_user.email.downcase)
    if @etudiant && @etudiant.formation
      incoming_cours = @etudiant.formation.cours.confirmé.order(:debut)

      @cours_today = incoming_cours.where("DATE(debut) = ?", Date.today)

      if @cours_today.empty?
        @next_cours = incoming_cours.where("DATE(debut) > ?", Date.today).first(3)
      end
    else
      redirect_to root_path
    end
  end

  def mes_sessions_intervenant
    if params[:presence_slug].present?
      if presence = Presence.find_by(slug: params[:presence_slug]) 
        @intervenant = presence.intervenant
      end
    elsif user_signed_in?
      @intervenant = Intervenant.find_by("LOWER(intervenants.email) = ?", current_user.email.downcase)
    end
    
    if @intervenant
      incoming_cours = @intervenant.cours.confirmé.order(:debut)
      @cours_today = incoming_cours.where("DATE(debut) = ?", Date.today)
      if @cours_today.empty?
        @next_cours = incoming_cours.where("DATE(debut) > ?", Date.today).first(3)
      end
    else
      redirect_to root_path, alert: "Vous devez vous connecter ou cliquer sur le lien reçu par email pour accéder à cette page"
    end
  end

  def signature_etudiant
    @cour = Cour.find(params[:cour_id])
    authorize @cour

    @etudiant = @cour.etudiants.find_by("LOWER(etudiants.email) = ?", current_user.email.downcase)
    @presence = Presence.find_or_create_by(cour_id: @cour.id, etudiant_id: @etudiant.id, code_ue: @cour.code_ue)
  end

  def signature_etudiant_do
    @presence = Presence.find(params[:presence][:id])
    authorize @presence.cour

    now = ApplicationController.helpers.time_in_paris_selon_la_saison
    @presence.workflow_state = 'signée'
    @presence.ip = request.remote_ip
    @presence.signature = params[:presence][:signature]
    @presence.signée_le = now
    if @presence.save
      redirect_to mes_sessions_etudiant_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def signature_intervenant
    @presence = Presence.find_by(slug: params[:presence_slug])
    @cour = @presence.cour
  end

  def signature_intervenant_do
    @presence = Presence.find(params[:presence][:id])
    authorize @presence.cour

    now = ApplicationController.helpers.time_in_paris_selon_la_saison
    @presence.workflow_state = 'signée'
    @presence.ip = request.remote_ip
    @presence.signature = params[:presence][:signature]
    @presence.signée_le = now
    if @presence.save
      @presence.cour.presences.where(workflow_state: 'signée').update_all(workflow_state: 'validée')

      @presence.cour.presences.where(workflow_state: 'attente signature').update_all(workflow_state: 'manquante')

      absents = @presence.cour.etudiants.where.not(id: @presence.cour.presences.pluck(:etudiant_id))

      absents.each do |absent|
        @presence.cour.presences.create(etudiant_id: absent.id, workflow_state: 'manquante', code_ue: @presence.cour.code_ue)
      end
      flash[:notice] = 'Toutes les signatures de présences ont été validées. Les étudiants qui n\'ont pas signé sont notés absents.'
      redirect_to mes_sessions_intervenant_path(presence_slug: @presence.slug)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def delete_attachment
    @cour.document.purge
    redirect_to @cour, notice: 'Document supprimée.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cour
      @cour = Cour.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cour_params
      params.require(:cour).permit(:debut, :fin, :formation_id, :intervenant_id,
                                    :salle_id, :code_ue, :nom, :etat, :duree,
                                    :intervenant_binome_id, :hors_service_statutaire,
                                    :commentaires, :elearning, :document, :no_send_to_edusign,
                                    options_attributes: [:id, :user_id, :catégorie, :description, :_destroy])
    end

    def is_user_authorized
      authorize Cour
    end

    def etudiants_selected_ids
      etudiants_ids = []
      etudiants_ids += params[:etudiants_id].keys if params[:etudiants_id].present?
      etudiants_ids += params[:etudiants_en_rattrapage_ids] if params[:etudiants_en_rattrapage_ids].present?
      etudiants_ids.uniq!
      etudiants_ids
    end

  end
