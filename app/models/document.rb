class Document < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited associated_with: :dossier

  belongs_to :dossier
  has_one_attached :fichier

  DEPOSE = 'déposé'
  VALIDE = 'validé'
  REJETE = 'rejeté'
  ARCHIVE= 'archivé'

  workflow do
    state DEPOSE do
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
    end
    state VALIDE do
      event :archiver, transitions_to: ARCHIVE
    end
    state REJETE do
      event :archiver, transitions_to: ARCHIVE
    end
    state ARCHIVE
  end

  def self.types
    ["Acte d'engagement", "Justificatif d'activité", "RIB", "Carte d'identité/Passport", 'Carte vitale', 'Attestation Sécurité Sociale', 'CV', 'Attestation de cumul', 'Extrait K-BIS', "Avis d'imposition", 'Attestation URSSAF', 'Carte étudiant', 'Titre de pension'].sort
  end
end
