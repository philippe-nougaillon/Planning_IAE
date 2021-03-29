class Dossier < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited

  belongs_to :intervenant
  has_many :documents

  workflow do
    state :nouveau
    state :envoyé
    state :crée
    state :validé
    state :refusé
    state :archivé
  end

end
