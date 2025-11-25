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
  has_many :options, dependent: :destroy
  accepts_nested_attributes_for :options,
                                reject_if: lambda{|attributes| attributes['catégorie'].blank? || attributes['description'].blank?},
                                allow_destroy:true
  has_many :attendances, dependent: :destroy
  has_one :sujet, dependent: :destroy

  has_one_attached :document

  validates :debut, :formation_id, :intervenant_id, :duree, presence: true
  validate :check_chevauchement_intervenant, if: Proc.new {|cours| !(cours.bypass?)}
  validate :check_chevauchement, if: Proc.new { |cours| cours.salle_id && !(cours.bypass?) }
  validate :jour_fermeture, if: Proc.new {|cours| !(cours.bypass?)}
  validate :reservation_dates_must_make_sense
  validate :jour_ouverture, if: Proc.new { |cours| cours.salle && cours.salle.bloc != 'Z' && !(cours.bypass?) }
  validate :check_invits_en_cours
  validate :check_hss
  validate :check_intervenant_not_also_appear_in_binome, if: Proc.new {|cours| cours.intervenant_binome.present?}

  before_validation :update_date_fin
  before_validation :sunday_morning_praise_the_dawning

  before_save :change_etat_si_salle
  before_save :annuler_salle_si_cours_est_annulé

  around_update :check_send_commande_email
  after_create :check_send_new_commande_email

  if ENV["SEND_EXAMEN_EMAILS"] == "true"
    after_create   :send_new_examen_email, if: Proc.new { |cours| cours.examen? }
    around_update  :check_send_examen_email
    after_destroy :send_delete_examen_email, if: Proc.new { |cours| cours.examen? }
  end
  
  after_update :synchronisation_edusign, if: Proc.new { |cours| cours.audits.last.audited_changes["salle_id"] && cours.edusign_id && !cours.no_send_to_edusign && cours.formation.send_to_edusign}

  # Mettre à jour les SCENIC VIEWS
  after_commit {
    CoursNonPlanifie.refresh
  }

  enum :etat, [:planifié, :à_réserver, :confirmé, :reporté, :annulé, :réalisé]

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
      actions << ["Générer Feuille émargement PDF", "Convocation étudiants PDF"]
    else
      actions << ["Supprimer", "Changer de salle", "Changer d'intervenant", "Intervertir"]
    end

    if user.role_number >= 5
      actions << ["Changer d'état", "Changer de date", "Inviter", "Générer Feuille émargement PDF", "Générer Feuille émargement présences signées PDF", "Générer Pochette Examen PDF", "Convocation étudiants PDF"]
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
    Cour.confirmé.where("DATE(cours.debut) >= ?", Date.today).where("cours.commentaires LIKE '+%'").order(:debut)
  end

  def self.commandes_archivées
    Cour.réalisé.where("DATE(cours.debut) < ?", Date.today).where("cours.commentaires LIKE '+%'").order(debut: :desc)
  end

  def self.commandes_v2
    Cour.confirmé.where("DATE(cours.debut) >= ?", Date.today).joins(:options).where(options: {catégorie: :commande}).order(:debut)
  end

  def self.commandes_archivées_v2
    Cour.réalisé.where("DATE(cours.debut) < ?", Date.today).joins(:options).where(options: {catégorie: :commande}).order(debut: :desc)
  end

  def self.etats_humanized
    self.etats.transform_keys(&:humanize)
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
    self.formation.nbr_etudiants > self.salle.places && self.salle.bloc != 'Z'
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
    "#{self.nom} (#{self.formation.nbr_etudiants})" 
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
    self.formation.nom || ""
  end

  def salle_json_v2
    self.salle.try(:nom)
  end

  def debut_fin_json_v2
    self.debut.to_s[11..15] + " - " + self.fin.to_s[11..15]
  end

  def formation_color_json_v2
      self.formation.color
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

  def self.taux_horaire_vacation
    11.88
  end

  def taux_td
    case Formation.find(self.formation_id).nomtauxtd
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
    case Formation.find(self.formation_id).nomtauxtd
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
    !(self.hors_service_statutaire || Formation.find(self.formation_id).hss)
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
    ((now.to_f - self.debut.in_time_zone('Paris').to_f) / (self.fin.in_time_zone('Paris').to_f - self.debut.in_time_zone('Paris').to_f) * 100).to_f
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

  # PGSearch Attributs
  def formation_nom
    self.formation.nom
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
      event.url = "https://planning.iae-paris.com/"
      calendar.add_event(event)
    end  
    return calendar
  end

  # Si c'est un examen IAE / examen rattrapage / Tiers-temps
  def examen?
    [169, 1166, 522].include?(self.intervenant.id)
  end

  def type_examen
    case self.intervenant_id
    when 169
      "Examen"
    when 1166
      "Examen Rattrapage"
    when 522
      "Examen Tiers-Temps"
    end
  end

  def signable_etudiant?
    now = ApplicationController.helpers.time_in_paris_selon_la_saison
    (self.debut - 10.minutes < now && self.debut + 30.minutes > now)
  end

  def signable_intervenant?
    now = ApplicationController.helpers.time_in_paris_selon_la_saison
    (now > self.debut + 30.minutes)
  end

  def bypass?
    (self.commentaires && self.commentaires.include?("BYPASS=#{self.id}"))
  end

  # def désynchronisé?
  #   # Regarde si un cours réalisé d'une formation étant sur Edusign n'a aucune présence de créé.
  #   Formation.where(send_to_edusign: true).pluck(:id).include?(self.formation_id) && self.réalisé? && self.attendances.empty?
  # end

  def changements_examen
    saved_changes.except("updated_at", "created_at")
  end

  def days_between_today_and_debut
    (self.debut.to_date - Date.today).to_i
  end

  def color_sujet
    case self.sujet&.workflow_state
    when 'validé', 'archivé'
      "success"
    when 'déposé'
      "warning"
    else
      "error"
    end
  end

  def sujet_manquant?
    if [169, 1166].include?(self.intervenant_id)
      sujet = Sujet.find_by(cour_id: self.id)
      if !['déposé', 'validé', 'archivé'].include?(sujet&.workflow_state)
        true
      else
        false
      end
    else
      false
    end
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

      # envoyer un mail à Pascal pour faire la réservation de cours
      #if self.changes.include?('etat') and (self.etat == 'à_réserver') 
      #  UserMailer.cours_changed(self.id, "wachnick.iae@univ-paris1.fr").deliver_later
      #end 
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
      cours = Cour.where(
      "intervenant_id = :intervenant_id AND 
      (
        (debut BETWEEN :debut AND :fin) OR
        (fin BETWEEN :debut AND :fin) OR
        (:debut BETWEEN debut AND fin) OR
        (:fin BETWEEN debut AND fin)
      )
      ", intervenant_id: self.intervenant_id, debut: self.debut, fin: self.fin)

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

    def check_hss
      if self.formation.hss && !self.hors_service_statutaire
        errors.add(:hors_service_statutaire, 'ne correspond pas à celui de la formation')
      end
    end

    def check_send_commande_email
      old_commentaires = commentaires_was
      yield
      commande_status = determine_statut_commande(old_commentaires, commentaires)
      send_email_commande(commande_status, old_commentaires)
    end

    def determine_statut_commande(old_commentaires, new_commentaires)
      if old_commentaires && old_commentaires.include?('+')
        new_commentaires.include?('+') ? 'modifiée' : 'supprimée'
      elsif new_commentaires && new_commentaires.include?('+')
        'ajoutée'
      else
        ''
      end
    end

    def send_email_commande(commande_status, old_commentaires)
      case commande_status
      when 'modifiée'
        ToolsMailer.with(cour: self, old_commentaires: old_commentaires).commande_modifiée.deliver_now
      when 'supprimée'
        ToolsMailer.with(cour: self, old_commentaires: old_commentaires).commande_supprimée.deliver_now
      when 'ajoutée'
        ToolsMailer.with(cour: self).nouvelle_commande.deliver_now
      end
    end

    def check_send_new_commande_email
      if self.commentaires && self.commentaires.include?('+')
        ToolsMailer.with(cour: self).nouvelle_commande.deliver_now
      end
    end

    def check_send_examen_email
      old_cour = self.dup
      old_cour.intervenant_id = intervenant_id_was

      yield

      # Check si le cour était ou est un examen
      if Intervenant.find_by(id: old_cour.intervenant_id).try(:examen?) || self.examen?
        examen_status = determine_statut_examen(old_cour.intervenant_id, self.intervenant_id)
        send_email_examen(examen_status, old_cour)
      end
    end

    def determine_statut_examen(old_intervenant_id, new_intervenant_id)
      if old_intervenant_id != new_intervenant_id
        # On passe d'un type d'examen à un autre
        if Intervenant.find(new_intervenant_id).examen? && Intervenant.find_by(id: old_intervenant_id).try(:examen?)
          'modifié'
        # L'examen devient un cours
        elsif Intervenant.find_by(id: old_intervenant_id).try(:examen?)
          'supprimé'
        # Un cours devient un examen
        else
          'ajouté'
        end
      else
        # Cas de loin le plus probable : un examen change de propriété
        'modifié'
      end
    end

    def send_email_examen(examen_status, old_cour)
      title = ""
      case examen_status
      when 'modifié'
        title = "[PLANNING] Examen modifié pour le #{I18n.l self.debut, format: :long}"
        mailer_response = CourMailer.with(cour: self, title: title).examen_modifié.deliver_now
      when 'supprimé'
        title = "[PLANNING] Examen supprimé pour le #{I18n.l self.debut, format: :long}"
        mailer_response = CourMailer.with(cour: self, title: title).examen_supprimé.deliver_now
      when 'ajouté'
        title = "[PLANNING] Nouvel examen pour le #{I18n.l self.debut, format: :long}"
        mailer_response = CourMailer.with(cour: self, title: title).examen_ajouté.deliver_now
      end
      MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: "examens@iae.pantheonsorbonne.fr", subject: "Examen #{examen_status}", title: title)
    end

    def send_new_examen_email
      title = "[PLANNING] Nouvel examen pour le #{I18n.l self.debut, format: :long}"
      mailer_response = CourMailer.with(cour: self, title: title).examen_ajouté.deliver_now
      MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: "examens@iae.pantheonsorbonne.fr", subject: "Examen ajouté", title: title)
    end

  def send_delete_examen_email
    title = "[PLANNING] Examen supprimé pour le #{I18n.l self.debut, format: :long}"
    mailer_response = CourMailer.with(cour: self, title: title).examen_supprimé.deliver_now
    MailLog.create!(user_id: 0, message_id: mailer_response.message_id, to: "examens@iae.pantheonsorbonne.fr", subject: "Examen supprimé", title: title)
  end

  def synchronisation_edusign
    # Modifier la salle sur Edusign si changement
    EdusignJob.perform_later("salle changée", self.audits.last.user_id, {cour_id: self.id})
  end

  def check_intervenant_not_also_appear_in_binome
    if self.intervenant == self.intervenant_binome
      errors.add(:cours, "ne peut pas avoir l'intervenant apparaitre aussi en tant que binôme !")
    end
  end

end