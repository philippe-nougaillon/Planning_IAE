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

end
