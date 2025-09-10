class Dossier < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  belongs_to :intervenant

  has_many :documents, dependent: :destroy
  belongs_to :mail_log, optional: true

  has_associated_audits

  accepts_nested_attributes_for :documents, 
                                allow_destroy:true, 
                                reject_if: lambda {|attributes| attributes['nom'].blank? }

  default_scope { order('dossiers.updated_at DESC') }                              
                              
  # WORKFLOW

  NOUVEAU = 'nouveau'
  ENVOYE  = 'envoyé'
  RELANCE1  = 'relancé 1 fois'
  RELANCE2  = 'relancé 2 fois'
  RELANCE3  = 'relancé 3 fois'
  RELANCE4  = 'relancé 4 fois'
  RELANCE5  = 'relancé 5 fois'
  RELANCE6  = 'relancé 6 fois'
  RELANCE7  = 'relancé 7 fois'
  RELANCE8  = 'relancé 8 fois'
  RELANCE9  = 'relancé 9 fois'
  RELANCE10 = 'relancé 10 fois'
  DEPOSE  = 'déposé'
  VALIDE  = 'validé'
  REJETE  = 'non_conforme'
  ARCHIVE = 'archivé'

  workflow do
    state NOUVEAU, meta: {style: 'badge-info'} do
      event :envoyer, transitions_to: ENVOYE
    end

    state ENVOYE, meta: {style: 'badge-primary'} do
      event :relancer, transitions_to: RELANCE1
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE1, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE2
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE2, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE3
      event :déposer, transitions_to: DEPOSE
    end
    
    state RELANCE3, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE4
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE4, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE5
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE5, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE6
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE6, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE7
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE7, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE8
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE8, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE9
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE9, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE10
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE10, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE1
      event :déposer, transitions_to: DEPOSE
    end
    
    state DEPOSE, meta: {style: 'badge-warning'} do
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
    end

    state VALIDE, meta: {style: 'badge-success'} do
      event :archiver, transitions_to: ARCHIVE
    end

    state REJETE, meta: {style: 'badge-error'} do
      event :déposer, transitions_to: DEPOSE
    end

    state ARCHIVE, meta: {style: 'badge-secondary'}
  end

  # pour que le changement se voit dans l'audit trail
  def persist_workflow_state(new_value)
    self[:workflow_state] = new_value
    save!
  end
  
  def style
    self.current_state.meta[:style]
  end

  def self.périodes
    ['2021/2022','2022/2023','2023/2024','2024/2025', '2025/2026', '2026/2027']
  end

  def self.xls_headers
    %w{ Id Nom Prénom Période Etat Mémo Documents Date_création Date_MAJ }
  end

  def self.to_xls(dossiers)
    require 'spreadsheet'    

    Spreadsheet.client_encoding = 'UTF-8'

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Dossiers_Candidatures_CEV'
    bold = Spreadsheet::Format.new :weight => :bold, :size => 11

    sheet.row(0).concat self.xls_headers
    sheet.row(0).default_format = bold

    index = 1
    dossiers.each do | dossier |
      fields_to_export = [
        dossier.id, 
        dossier.intervenant.nom,
        dossier.intervenant.prenom,
        dossier.période,
        dossier.workflow_state,
        dossier.mémo,
        dossier.documents.pluck(:nom, :workflow_state).join(', '),
        dossier.created_at, 
        dossier.updated_at
      ]
      sheet.row(index).replace fields_to_export
      index += 1
    end
    return book

  end
  
  def envoyer_dossier(id)
    # Passe le dossier à l'état 'Envoyé'
    self.envoyer!

    # Informe l'intervenant
    DossierMailerJob.perform_later(self.id, id, :dossier_email)
  end

  def valider_dossier(id)
    # Valide tous les documents
    self.documents.each do | doc |
      doc.valider! if doc.can_valider?
    end

    # Passe le dossier à l'état 'Validé'
    self.valider!

    # Informe l'intervenant
    DossierMailerJob.perform_later(self.id, id, :valider_email)
  end

  def relancer_dossier(id)
    # Passe le dossier à l'état 'Relancé'
    self.relancer!

    # Informe l'intervenant
    DossierMailerJob.perform_later(self.id, id, :dossier_email)
  end

  def rejeter_dossier(id)
    # Vérifier qu'il y a au moins un document à l'état rejeté
    rejeter = false
    self.documents.each do | doc |
      rejeter = true if doc.non_conforme?
    end
    
    if rejeter
      # Passe le dossier à l'état 'Rejeté'
      self.rejeter!

      # Informe l'intervenant
      DossierMailerJob.perform_later(self.id, id, :rejeter_email)

      return true
    else
      return false
    end
  end

  def archiver_dossier(id)
    self.documents.each do | doc |
      if doc.validé?
        doc.fichier.purge
        doc.archiver!
      elsif doc.non_conforme?
        doc.destroy
      end
    end
    self.archiver!
  end

  def available_states
    # On prends tous les états à l'exception de "déposé"
    Dossier.workflow_spec.states.keys.to_a.select do |state|
      case state
      when :envoyé
        self.can_envoyer?
      when :"relancé 1 fois"
        self.can_relancer? && self.current_state.to_s == "envoyé"
      when :"relancé 2 fois"
        self.can_relancer? && self.current_state.to_s == "relancé 1 fois"
      when :"relancé 3 fois"
        self.can_relancer? && self.current_state.to_s == "relancé 2 fois"
      when :"relancé 4 fois"
        self.can_relancer? && self.current_state.to_s == "relancé 3 fois"
      when :"relancé 5 fois"
        self.can_relancer? && self.current_state.to_s == "relancé 4 fois"
      when :"relancé 6 fois"
      self.can_relancer? && self.current_state.to_s == "relancé 5 fois"
      when :"relancé 7 fois"
      self.can_relancer? && self.current_state.to_s == "relancé 6 fois"
      when :"relancé 8 fois"
      self.can_relancer? && self.current_state.to_s == "relancé 7 fois"
      when :"relancé 9 fois"
      self.can_relancer? && self.current_state.to_s == "relancé 8 fois"
      when :"relancé 10 fois"
      self.can_relancer? && self.current_state.to_s == "relancé 9 fois"
      when :validé
        self.can_valider?
      when :non_conforme
        self.can_rejeter?
      when :archivé
        self.can_archiver?
      else
        false
      end
    end
  end

  def self.state_to_method 
    return {
      :envoyé             => :envoyer_dossier,
      :"relancé 1 fois"   => :relancer_dossier,
      :"relancé 2 fois"   => :relancer_dossier,
      :"relancé 3 fois"   => :relancer_dossier,
      :"relancé 4 fois"   => :relancer_dossier,
      :"relancé 5 fois"   => :relancer_dossier,
      :"relancé 6 fois"   => :relancer_dossier,
      :"relancé 7 fois"   => :relancer_dossier,
      :"relancé 8 fois"   => :relancer_dossier,
      :"relancé 9 fois"   => :relancer_dossier,
      :"relancé 10 fois"  => :relancer_dossier,
      :validé             => :valider_dossier,
      :non_conforme       => :rejeter_dossier,
      :archivé            => :archiver_dossier 
    }
  end
  
private

  # only one candidate for an nice id; one random UDID
  def slug_candidates
    [SecureRandom.uuid]
  end

end
