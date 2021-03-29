class Dossier < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited

  belongs_to :intervenant
  has_many :documents
  accepts_nested_attributes_for :documents, 
                                allow_destroy:true, 
                                reject_if: lambda {|attributes| 
                                                    attributes['nom'].blank? || 
                                                    attributes['fichier'].blank?}

  workflow do
    state :nouveau
    state :envoyé
    state :crée
    state :validé
    state :refusé
    state :archivé
  end

end
