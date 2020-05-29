class Document < ApplicationRecord
  
  audited

  # mount_uploader :fichier, DocumentUploader

  belongs_to :formation
  belongs_to :intervenant
  belongs_to :unite

  validates :nom, :formation_id, :intervenant_id, :fichier, presence:true

end
