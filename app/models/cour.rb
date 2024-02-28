# Encoding: utf-8

class Cour < ApplicationRecord
	include PgSearch::Model

  multisearchable against: [:nom_ou_ue, :formation_nom, :intervenant_nom, :commentaires]
  audited
  
  belongs_to :formation
  belongs_to :intervenant
  belongs_to :intervenant_binome, class_name: :Intervenant, foreign_key: :intervenant_binome_id, optional: true 
  belongs_to :salle, optional: true

  has_many :invits
  has_many :presences
  has_many :etudiants, through: :formation

  validates :debut, :formation_id, :intervenant_id, :duree, presence: true
  validate :check_chevauchement_intervenant
  validate :check_chevauchement, if: Proc.new { |cours| cours.salle_id }
  validate :jour_fermeture
  validate :reservation_dates_must_make_sense
  validate :jour_ouverture, if: Proc.new { |cours| cours.salle && cours.salle.bloc != 'Z' }
  validate :check_invits_en_cours

  before_validation :update_date_fin
  before_validation :sunday_morning_praise_the_dawning

  before_save :change_etat_si_salle
  before_save :annuler_salle_si_cours_est_annulé

  # Mettre à jour les SCENIC VIEWS
  after_commit {
    CoursNonPlanifie.refresh
  }

  enum etat: [:planifié, :à_réserver, :confirmé, :reporté, :annulé, :réalisé]
  

  self.per_page = 20

  def self.styles
    ['info', 'warning', 'success', 'error', 'error', 'secondary']
  end

  def style
    Cour.styles[
      Cour.etats[
        self.etat = self.etat || 'planifié'
      ]
    ]
  end
  
  def self.actions(user)
    actions = ["Exporter vers Excel", "Exporter vers iCalendar", "Exporter en PDF"]

    if user.partenaire_qse?
      actions << ["Générer Feuille émargement PDF"]
    else
      actions << ["Supprimer", "Changer de salle", "Changer d'intervenant", "Intervertir"]
    end

    if user.role_number >= 5
      actions << ["Changer d'état", "Changer de date", "Inviter", "Générer Feuille émargement PDF", "Générer Pochette Examen PDF", "Convocation étudiants PDF"]
    end
    return actions.flatten.sort
  end

  def self.etendue_horaire
    [8,9,10,11,12,13,14,15,16,17,18,19,20,21,22]
  end

  def self.ue_styles
    ['#D4D8D1','#A8A8A1','#AA9A66','#B74934','#577492','#67655D','#332C2F','#432C2F','#732C2F','#932C2F']
  end

  def self.cumul_heures(start_date)
    nombre_heures_cours_jour = nombre_heures_cours_soir = 0
    Cour.where(etat: Cour.etats.values_at(:confirmé, :réalisé)).where("Date(debut) = ? ", start_date).each do |c|
      # si le cours commence avant 18h
      if c.debut.hour < 18
        nombre_heures_cours_jour += c.duree.to_f
      else
        nombre_heures_cours_soir += c.duree.to_f
      end
    end
    return [nombre_heures_cours_jour, nombre_heures_cours_soir]   
  end

  def self.xls_headers
      %w{id Date_début Heure_début Date_fin Heure_fin Formation_id Formation
          code_analytique Intervenant_id Intervenant Binôme UE Intitulé Etat
          Salle Durée E-learning? HSS? Taux_TD HETD Commentaires Créé_le Par Modifié_le}  
  end

  def self.durées
    ['0.5','1.0','1.5','2.0','2.5','3.0','3.5','4.0','4.5','5.0','5.5',
     '6.0','6.5','7.0','7.5','8.0','8.5','9.0','9.5',
     '10.0','10.5','11.0','11.5','12.0','12.5','13.0','13.5','14.0']
  end  

  def self.commandes
    Cour.confirmé.where("DATE(cours.debut) >= ?", Date.today).where("cours.commentaires LIKE '%+%'").order(:debut)
  end

  # Simple_calendar attributes
  def start_time
    self.debut.to_datetime 
  end

  def end_time
    self.fin.to_datetime
  end

  def start_time_short_fr
    I18n.l(self.debut, format: :short) 
  end

  def manque_de_places? 
    (self.salle.places > 0 && Formation.unscoped.find(self.formation_id).nbr_etudiants > self.salle.places)
  end

  def nom_ou_ue
    begin
      if self.nom.blank?        
        if self.code_ue
          if ue = self.formation.unites.find_by(code: self.code_ue)
            ue.num_nom
          end        
        end  
      else
        "#{self.nom} #{self.elearning ? "(E-learning)" : ''}"
      end
    rescue Exception => e 
      "erreur => #{e}"
    end
  end

  def nom_et_étudiants
    "#{self.nom} (#{self.formation.try(:nbr_etudiants)})" 
  end

  def url?
    # Correct URL ?
    self.nom =~ /https?:\/\/[\S]+/
  end

  # render json methods
  # 

  def photo_json
    if self.intervenant.photo 
      self.intervenant.photo.url
    end 
  end

  def formation_json
    self.formation.nom_promo
  end

  def intervenant_json
    self.intervenant.nom_prenom
  end

  def intervenant_binome_json
    self.intervenant_binome.try(:nom_prenom)
  end

  def salle_json
    self.salle.nom if self.salle
  end

  def duree_json
    (self.fin - self.debut).to_f / 60
  end

  def matiere_json
    self.nom_ou_ue
  end

  # render json methods V2
  # 

  def formation_json_v2
    self.formation.try(:nom) || ""
  end

  def salle_json_v2
    self.salle.try(:nom)
  end

  def debut_fin_json_v2
    self.debut.to_s[11..15] + " - " + self.fin.to_s[11..15]
  end

  def formation_color_json_v2
      self.formation.try(:color)
  end

  # render json methods V3
  # 

  def date_json_v3
    I18n.l(self.debut.to_date)
  end


  # ETATS DE SERVICES 

  def self.Tarif
    43.50
  end

  def taux_td
    case Formation.unscoped.find(self.formation_id).nomtauxtd
    when 'TD'
      Cour.Tarif
    when 'CM'
      65.22
    when '3xTD'
      130.50
    else
      0
    end
  end

  def HETD
    case Formation.unscoped.find(self.formation_id).nomtauxtd
    when 'TD'
      1
    when 'CM'
      1.5
    when '3xTD'
      3
    else
      0
    end
  end

  def montant_service
    self.duree * self.taux_td
  end

  def imputable?
    !(self.hors_service_statutaire || Formation.unscoped.find(self.formation_id).hss)
  end


  # SLIDER

  def progress_bar_pct2
    # calcul le % de réalisation du cours
    now = ApplicationController.helpers.time_in_paris_selon_la_saison
    pct = ((now.to_f - self.debut.in_time_zone('Paris').to_f) / (self.fin.in_time_zone('Paris').to_f - self.debut.in_time_zone('Paris').to_f) * 100).to_i
    return (pct > 0 && pct <= 100) ? pct : nil
  end


  def progress_bar_pct3
    # calcul le % de réalisation du cours
    now = ApplicationController.helpers.time_in_paris_selon_la_saison
    pct = ((now.to_f - self.debut.in_time_zone('Paris').to_f) / (self.fin.in_time_zone('Paris').to_f - self.debut.in_time_zone('Paris').to_f) * 100).to_f
  end

  def range
    # retourne l'étendue d'un cours sous la forme d'une suite d'heures. Ex: 8 9 pour un cours de 8 à 10h
    range = []

    (self.debut.hour .. self.fin.hour).each do | hour |
       range << hour
    end 

    if range.size == 1  
      return range # afficher le créneau même si le cours ne dure qu'une demi-heure
    else
      return range[0..-2] # enlève le dernier créneau horaire pour ne pas afficher la dernière heure comme occupée
    end
  end

  def self.generate_xls(cours, exporter_binome, voir_champs_privés = false)
    require 'spreadsheet'    
    
    Spreadsheet.client_encoding = 'UTF-8'

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Planning'
		bold = Spreadsheet::Format.new :weight => :bold, :size => 10
	
    sheet.row(0).concat Cour.xls_headers
		sheet.row(0).default_format = bold
    
    index = 1
    cours.each do |c|
        formation = Formation.unscoped.find(c.formation_id)
        fields_to_export = [
            c.id, 
            I18n.l(c.debut.to_date), 
            c.debut.to_formatted_s(:time), 
            I18n.l(c.fin.to_date), 
            c.fin.to_formatted_s(:time), 
            c.formation_id, formation.nom_promo, formation.code_analytique, 
            c.intervenant_id, c.intervenant.nom_prenom,
            c.intervenant_binome.try(:nom_prenom), 
            c.code_ue, c.nom, 
            c.etat, (c.salle ? c.salle.nom : nil), 
            c.duree,
            (c.elearning ? "OUI" : nil), 
            (!(c.imputable?) ? "OUI" : nil),
            ((voir_champs_privés && c.imputable?) ? formation.taux_td : nil),
            ((voir_champs_privés && c.imputable?) ? c.HETD : nil),
            (voir_champs_privés ? c.commentaires : nil),
            c.created_at,
            c.audits.first.user.try(:email),
            c.updated_at
        ]
        sheet.row(index).replace fields_to_export
        #logger.debug "#{index} #{fields_to_export}"
        index += 1

        # créer une ligne d'export supplémentaire pour le cours en binome
        if exporter_binome and c.intervenant_binome
          fields_to_export[8] = c.intervenant_binome_id
          fields_to_export[9] = c.intervenant_binome.nom_prenom 
          sheet.row(index).replace fields_to_export
          index += 1
        end  
    end

    return book
  end

  # PGSearch Attributs
  def formation_nom
    self.formation.try(:nom)
  end

  def intervenant_nom
    self.intervenant.try(:nom_prenom)
  end

  def self.generate_ical(cours)
    require 'icalendar'
    
    calendar = Icalendar::Calendar.new

    calendar.timezone do |t|
      t.tzid = "Europe/Paris"
    end
    
    cours.each do | c |
      event = Icalendar::Event.new
      event.dtstart = c.debut.strftime("%Y%m%dT%H%M%S")
      event.dtend = c.fin.strftime("%Y%m%dT%H%M%S")
      event.summary = c.try(:formation).try(:nom)
      event.description = c.nom
      event.location = "BioPark #{c.salle.nom if c.salle}"
      event.url = "https://business-school-planning-demo-248ac1f2d92e.herokuapp.com/"
      calendar.add_event(event)
    end  
    return calendar
  end

  def self.generate_etats_services_csv(cours, intervenants, start_date, end_date)
    require 'csv'

    cours = cours.where(etat: Cour.etats[:réalisé])

    total_hetd = 0
    CSV.generate(col_sep:';', quote_char:'"', encoding:'UTF-8') do | csv |
        csv << ['Type','Intervenant','Date','Heure','Formation','Code','Intitulé','Etat','Commentaires',
                'Durée','HSS?','E-learning?','Binôme','CM/TD?', 'Taux_TD','HETD','Montant','Cumul_hetd','Dépassement?']
    
        intervenants.each do | intervenant |
      
          # Passe au suivant si intervenant est 'A CONFIRMER'
          next if intervenant.id == 445

          nbr_heures_statutaire = intervenant.nbr_heures_statutaire || 0

          cours_ids = cours.where(intervenant: intervenant).order(:debut).pluck(:id)
          cours_ids << cours.where(intervenant_binome: intervenant).pluck(:id)
          cours_ids = cours_ids.flatten

          cumul_hetd = 0.00

          @vacations = intervenant.vacations.where("date BETWEEN ? AND ?", start_date, end_date)
          @responsabilites = intervenant.responsabilites.where("debut BETWEEN ? AND ?", start_date, end_date)
      
          cours_ids.each do |id|
              c = Cour.find(id)

              if c.imputable?
                cumul_hetd += c.HETD
                montant_service = c.montant_service.round(2)
              end

              formation = Formation.unscoped.find(c.formation_id)

              fields_to_export = [
                'C',
                intervenant.nom_prenom,
                I18n.l(c.debut.to_date),
                c.debut.strftime("%k:%M"), 
                formation.abrg, 
                formation.code_analytique_avec_indice(c.debut), 
                c.nom_ou_ue,
                c.etat,
                c.commentaires,
                c.duree.to_s.gsub(/\./, ','),
                (c.hors_service_statutaire ? "OUI" : ''),
                (c.elearning ? "OUI" : ''), 
                (c.intervenant && c.intervenant_binome ? "OUI" : ''),
                c.CMTD?, 
                formation.taux_td.to_s.gsub(/\./, ','),
                c.HETD.to_s.gsub(/\./, ','),
                montant_service.to_s.gsub(/\./, ','),
                cumul_hetd.to_s.gsub(/\./, ','),
                ((nbr_heures_statutaire > 0) && (cumul_hetd >= nbr_heures_statutaire) ? "#{cumul_hetd - nbr_heures_statutaire}" : '')
              ]
              csv << fields_to_export
          end 

          @vacations.each do |vacation|
            if vacation.forfaithtd > 0
              montant_vacation = ((Cour.Tarif * vacation.forfaithtd) * vacation.qte).round(2)
            else
              montant_vacation = vacation.tarif * vacation.qte
            end
            fields_to_export = [
                  'V',
                  intervenant.nom_prenom,
                  vacation.date,
                  nil,
                  vacation.formation.nom,
                  vacation.formation.code_analytique,
                  vacation.titre,
                  nil, 
                  vacation.qte,
                  nil, nil, nil, nil,
                  vacation.forfaithtd.to_s.gsub(/\./, ','),
                  montant_vacation.to_s.gsub(/\./, ',')
                ]
            csv << fields_to_export
          end

          @responsabilites.each do |resp|
            montant_responsabilite = (resp.heures * Cour.Tarif).round(2)
            fields_to_export = [
                  'R',
                  intervenant.nom_prenom,
                  I18n.l(resp.debut),
                  I18n.l(resp.fin),
                  resp.formation.nom,
                  resp.formation.code_analytique,
                  resp.titre,
                  nil, 
                  resp.heures.to_s.gsub(/\./, ','), 
                  nil, nil, nil, nil, nil,
                  montant_responsabilite.to_s.gsub(/\./, ',')
                ]
            csv << fields_to_export
          end
        end
    end
  end

  def self.generate_etats_services_xls(cours, intervenants, start_date, end_date)
    require 'spreadsheet'    
    
    Spreadsheet.client_encoding = 'UTF-8'

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Etats de services'
		bold = Spreadsheet::Format.new :weight => :bold, :size => 10
	
    sheet.row(0).concat ['Type','Intervenant','Date','Heure','Formation','Code','Intitulé','Etat','Commentaires',
      'Durée','HSS?','E-learning?','Binôme','CM/TD?', 'Taux_TD','HETD','Montant','Cumul_hetd','Dépassement']

    sheet.row(0).default_format = bold
    
    index = 1
    total_hetd = 0
    
    intervenants.each do | intervenant |
      
      # Passe au suivant si intervenant est 'A CONFIRMER'
      next if intervenant.id == 445

      nbr_heures_statutaire = intervenant.nbr_heures_statutaire || 0

      cours_ids = cours.where(intervenant: intervenant).order(:debut).pluck(:id)
      cours_ids << cours.where(intervenant_binome: intervenant).pluck(:id)
      cours_ids = cours_ids.flatten

      cumul_hetd = 0.00

      @vacations = intervenant.vacations.where("date BETWEEN ? AND ?", start_date, end_date)
      @responsabilites = intervenant.responsabilites.where("debut BETWEEN ? AND ?", start_date, end_date)
  
      cours_ids.each do |id|
          c = Cour.find(id)

          if c.imputable?
            cumul_hetd += c.HETD
            montant_service = c.montant_service.round(2)
          end

          formation = Formation.unscoped.find(c.formation_id)

          fields_to_export = [
            'C',
            intervenant.nom_prenom,
            I18n.l(c.debut.to_date),
            c.debut.strftime("%k:%M"), 
            formation.abrg, 
            formation.code_analytique_avec_indice(c.debut), 
            c.nom_ou_ue,
            c.etat,
            c.commentaires,
            c.duree,
            (c.hors_service_statutaire ? "OUI" : ''),
            (c.elearning ? "OUI" : ''), 
            (c.intervenant && c.intervenant_binome ? "OUI" : ''),
            formation.nomtauxtd, 
            c.taux_td,
            c.HETD,
            montant_service,
            cumul_hetd,
            ((nbr_heures_statutaire > 0) && (cumul_hetd >= nbr_heures_statutaire) ? cumul_hetd - nbr_heures_statutaire : nil)
          ]

          sheet.row(index).replace fields_to_export
          index += 1
      end 

      @vacations.each do |vacation|
        if vacation.forfaithtd > 0
          montant_vacation = ((Cour.Tarif * vacation.forfaithtd) * vacation.qte).round(2)
          cumul_hetd += (vacation.qte * vacation.forfaithtd)
        else
          montant_vacation = vacation.tarif * vacation.qte
        end
        formation = Formation.unscoped.find(vacation.formation_id)
        
        fields_to_export = [
              'V',
              intervenant.nom_prenom,
              I18n.l(vacation.date.to_date),
              nil,
              formation.nom,
              formation.code_analytique,
              vacation.titre,
              nil, nil, 
              vacation.qte,
              nil, nil, nil, 
              'TD', 1,
              vacation.forfaithtd,
              montant_vacation,
              cumul_hetd,
              ((nbr_heures_statutaire > 0) && (cumul_hetd >= nbr_heures_statutaire) ? cumul_hetd - nbr_heures_statutaire : nil)
            ]
        sheet.row(index).replace fields_to_export
        index += 1
      end

      @responsabilites.each do |resp|
        montant_responsabilite = (resp.heures * Cour.Tarif).round(2)
        cumul_hetd += resp.heures
        formation = Formation.unscoped.find(resp.formation_id)

        fields_to_export = [
              'R',
              intervenant.nom_prenom,
              I18n.l(resp.debut),
              nil,
              formation.nom,
              formation.code_analytique,
              resp.titre,
              nil,
              nil, 
              resp.heures, 
              nil, nil, nil,
              'TD', 1, nil,
              montant_responsabilite,
              cumul_hetd,
              ((nbr_heures_statutaire > 0) && (cumul_hetd >= nbr_heures_statutaire) ? cumul_hetd - nbr_heures_statutaire : nil)
        ]
        sheet.row(index).replace fields_to_export
        index += 1
      end
    end

    return book 
  end

  # Si c'est un certain id
  def examen?
    [169, 1166, 522].include?(self.intervenant.id)
  end

  # def self.cours_a_planifier
  #   # ids des cours créés par utilisateur autre que le user (#41)
  #   # vérifie que la date de début de cours est dans la période observée
  #   Cour.where("id IN (?)", Audited::Audit.where(auditable_type: 'Cour').where.not(user_id: 41).pluck(:auditable_id).uniq)
  #       .planifié
  #       .where("cours.debut BETWEEN ? AND ?", Date.today, Date.today + 30.days)
  #       .count
  # end

  def signable_etudiant?
    now = ApplicationController.helpers.time_in_paris_selon_la_saison
    (self.debut - 10.minutes < now && self.debut + 30.minutes > now)
  end

  def signable_intervenant?
    now = ApplicationController.helpers.time_in_paris_selon_la_saison
    (now > self.debut + 30.minutes)
  end

  private
    def update_date_fin
      if self.debut and self.duree
        fin = eval("self.debut + self.duree.hour")
        self.fin = fin if self.fin != fin
      end
    end

    def sunday_morning_praise_the_dawning # :)
      if self.debut.wday == 0
        errors.add(:cours, "ne peut pas avoir lieu un dimanche !")
      end
    end

    def call_notifier
      # envoyer un mail si le cours a changé d'état vers annulé ou reporté
      if self.changes.include?('etat') and (self.etat == 'annulé' or self.etat == 'reporté') 
        # logger.debug "[DEBUG] etat modifié: #{self.etat_was} => #{self.etat}"

        # envoyer notification au chargé de formation
        if self.formation.user
          UserMailer.cours_changed(self.id, self.formation.user.email, self.etat).deliver_later
        end

        # envoyer à tous les étudiants 
        self.formation.etudiants.each do | etudiant |
          UserMailer.cours_changed(self.id, etudiant.email, self.etat).deliver_later
        end
      end
    end  

    def reservation_dates_must_make_sense
      unless fin 
        errors.add(:fin, "du cours doit être précisée !")
      else
        if fin <= debut 
          errors.add(:fin, "du cours ne peut pas être avant son commencement !")
        end
      end  
    end

    def check_chevauchement

      # Pas de test si les doublons sont autorisés
      return if self.salle.places == 0
            
      # s'il y a dejà des cours dans la même salle et à la même date
      cours = Cour.where("salle_id = ? AND (((debut BETWEEN ? AND ?) OR (fin BETWEEN ? AND ?)) OR (debut < ? AND fin > ?))", 
                          self.salle_id, self.debut, self.fin, self.debut, self.fin, self.fin, self.debut)

      # si cours en chevauchement n'est pas le cours lui même (modif de cours)
      cours = cours.where.not(id:self.id).where.not(fin:self.debut).where.not(debut:self.fin)

      if cours.any?
        cours_links = []
        cours.each do |c| 
          cours_links << "<a href='/cours/#{c.id}'>#{c.id}</a>"
        end
        errors.add(:cours, "en chevauchement (période, salle) avec le cours #{cours_links.join(',')}")
      end
    end  

    def check_chevauchement_intervenant

      # Pas de test si pas d'intervenant
      return unless self.intervenant
      # Pas de test si les doublons sont autorisés
      return if self.intervenant.doublon 

      # s'il y a dejà des cours pour le même intervenant à la même date
      cours = Cour.where("intervenant_id = ? AND ((debut BETWEEN ? AND ?) OR (fin BETWEEN ? AND ?))", 
                          self.intervenant_id, self.debut, self.fin, self.debut, self.fin)

      # si cours en chevauchement n'est pas le cours lui même (modif de cours)
      cours = cours.where.not(id: self.id)
                    .where.not(fin: self.debut)
                    .where.not(debut: self.fin)

      if cours.any?
        errors.add(:cours, "en chevauchement (période, intervenant) avec le(s) cours ##{cours.pluck(:id).join(',')}")
      end
    end  

    def jour_fermeture
      if Fermeture.find_by(date:self.debut.to_date)
        errors.add(:cours, 'sur une date de fermeture !')
      end
    end

    def change_etat_si_salle
      if (self.etat == 'planifié' or self.etat == 'à_réserver' or self.etat == 'confirmé') and (self.salle_id_was == nil and self.salle_id != nil)
          self.etat = 'confirmé'
          errors.add(:cours, 'état changé !')
      end   
    end

    def annuler_salle_si_cours_est_annulé
      if (self.etat == 'annulé') and (self.salle_id != nil)
          self.salle_id = nil
          errors.add(:cours, 'état changé & salle libérée ')
      end   
    end

    def jour_ouverture
      if horaire = Ouverture.where(jour: self.debut.to_date.wday).find_by(bloc: self.salle.bloc)
        unless ((self.debut.hour >= horaire.début.hour) && 
          (self.fin.hour <= horaire.fin.hour) && 
          (self.debut.hour < horaire.fin.hour) && 
          (self.fin.hour > horaire.début.hour))
          errors.add(:cours, 'en dehors des horaires d\'ouverture')
        end
      else
        errors.add(:cours, 'impossible à valider : problème avec les horaires d\'ouverture !')
      end
    end
  
    def check_invits_en_cours
      if self.invits.where.not("workflow_state = 'non_retenue' OR  workflow_state = 'confirmée'").any? && self.intervenant != 445
        errors.add(:cours, 'a des invitations en cours !')
      end
    end
end
