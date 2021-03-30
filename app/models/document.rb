class Document < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited

  belongs_to :dossier
  has_one_attached :fichier

  workflow do
    state :nouveau
    state :validé
    state :refusé
  end

  def self.types
    ["Acte d'engagement", "Justificatif d'activité", "RIB", "Carte d'identité/Passport", 'Carte vitale', 'Attestation Sécurité Sociale', 'CV', 'Attestation de cumul', 'Extrait K-BIS', "Avis d'imposition", 'Attestation URSSAF', 'Carte étudiant', 'Titre de pension'].sort
  end
end
