# Encoding: utf-8

class ImportLog < ApplicationRecord

  belongs_to :user
  has_many :import_log_lines

  validates :model_type, :etat, presence: true

  enum etat: [:succès, :echec, :warning]

  def icon_etat
    case self.etat
    when "succès"
      "glyphicon glyphicon-ok-circle text-success"
    when "echec"
      "glyphicon glyphicon-remove-circle text-danger"
    when "warning"
      "glyphicon glyphicon-remove-circle text-warning"
    end
  end  
    
end
