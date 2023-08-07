class Dossier < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  belongs_to :intervenant

  has_many :documents, dependent: :destroy
  has_associated_audits

  accepts_nested_attributes_for :documents, 
                                allow_destroy:true, 
                                reject_if: lambda {|attributes| attributes['nom'].blank? }

  default_scope { order('dossiers.updated_at DESC') }                              
                              
  # WORKFLOW

  NOUVEAU = 'nouveau'
  ENVOYE  = 'envoyé'
  RELANCE1= 'relancé 1 fois'
  RELANCE2= 'relancé 2 fois'
  RELANCE3= 'relancé 3 fois'
  DEPOSE  = 'déposé'
  VALIDE  = 'validé'
  REJETE  = 'non_conforme'
  ARCHIVE = 'archivé'

  workflow do
    state NOUVEAU, meta: {style: 'bg-info'} do
      event :envoyer, transitions_to: ENVOYE
    end

    state ENVOYE, meta: {style: 'bg-primary'} do
      event :relancer, transitions_to: RELANCE1
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE1, meta: {style: 'bg-info'} do
      event :relancer, transitions_to: RELANCE2
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE2, meta: {style: 'bg-info'} do
      event :relancer, transitions_to: RELANCE3
      event :déposer, transitions_to: DEPOSE
    end
    
    state RELANCE3, meta: {style: 'bg-info'} do
      event :relancer, transitions_to: RELANCE1
      event :déposer, transitions_to: DEPOSE
    end
    
    state DEPOSE, meta: {style: 'bg-warning'} do
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
    end

    state VALIDE, meta: {style: 'bg-success'} do
      event :archiver, transitions_to: ARCHIVE
    end

    state REJETE, meta: {style: 'bg-danger'} do
      event :déposer, transitions_to: DEPOSE
    end

    state ARCHIVE, meta: {style: 'bg-dark'}
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
    ['2021/2022','2022/2023','2023/2024','2024/2025', '2025/2026']
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
  
private

  # only one candidate for an nice id; one random UDID
  def slug_candidates
    [SecureRandom.uuid]
  end

end
