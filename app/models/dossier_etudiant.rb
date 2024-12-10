class DossierEtudiant < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  belongs_to :etudiant, optional: :true
  has_one_attached :certification

  # WORKFLOW

  NOUVEAU = 'nouveau'
  DEPOSE  = 'déposé'
  VALIDE  = 'validé'
  REJETE  = 'non_conforme'
  ARCHIVE = 'archivé'

  workflow do
    state NOUVEAU, meta: {style: 'badge-info'} do
      event :deposer, transitions_to: DEPOSE
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

    state ARCHIVE, meta: {style: 'badge-dark'}
  end

  def style
    self.current_state.meta[:style]
  end

  private

  # only one candidate for an nice id; one random UDID
  def slug_candidates
    [SecureRandom.uuid]
  end
end
