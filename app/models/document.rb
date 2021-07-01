class Document < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited associated_with: :dossier

  belongs_to :dossier
  has_one_attached :fichier

  DEPOSE = 'déposé'
  VALIDE = 'validé'
  REJETE = 'non_conforme'
  ARCHIVE= 'archivé'

  workflow do
    state DEPOSE, meta: {style: 'badge-warning'}  do
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
    end
    state VALIDE, meta: {style: 'badge-success'} do
      event :archiver, transitions_to: ARCHIVE
    end
    state REJETE, meta: {style: 'badge-danger'} do
      event :archiver, transitions_to: ARCHIVE
    end
    state ARCHIVE, meta: {style: 'badge-secondary'}
  end

  def style
    self.current_state.meta[:style]
  end

  def self.types
    [ "Dossier de recrutement", 
      "Justificatif d'activité", 
      "RIB", 
      "Carte d'identité/Passeport", 
      'Carte vitale', 
      'Attestation Sécurité Sociale', 
      'CV', 
      'Attestation de cumul', 
      'Extrait K-BIS', 
      "Avis d'imposition", 
      'Attestation URSSAF', 
      "Carte étudiant(e)", 
      'Titre de pension',
      'Autre'
    ]
  end
end
