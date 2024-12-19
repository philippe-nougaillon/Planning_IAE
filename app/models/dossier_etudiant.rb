class DossierEtudiant < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  belongs_to :etudiant, optional: :true
  has_one_attached :certification
  has_one_attached :pièce_identité
  has_one_attached :lettre_de_motivation
  has_one_attached :cv

  scope :ordered, -> {order(created_at: :desc)}

  # WORKFLOW
  DEPOSE  = 'déposé'
  VALIDE  = 'validé'
  REJETE  = 'non_conforme'
  ARCHIVE = 'archivé'

  workflow do
    state DEPOSE, meta: {style: 'badge-info'} do
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
    end

    state VALIDE, meta: {style: 'badge-success'} do
      event :archiver, transitions_to: ARCHIVE
    end

    state REJETE, meta: {style: 'badge-error'} do
      event :déposer, transitions_to: DEPOSE
      event :archiver, transitions_to: ARCHIVE
    end

    state ARCHIVE, meta: {style: 'badge-secondary'}
  end

  def style
    self.current_state.meta[:style]
  end

  def nom_prénom
    self.nom + ' ' + self.prénom
  end

  private

  # only one candidate for an nice id; one random UDID
  def slug_candidates
    [SecureRandom.uuid]
  end
end
