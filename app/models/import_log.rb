# Encoding: utf-8

class ImportLog < ApplicationRecord

  belongs_to :user
  has_many :import_log_lines

  validates :model_type, :etat, presence: true

  enum etat: [:succès, :echec, :warning]

  def icon_etat
    if self.etat == 'succès'
      'check-circle'
    else
      'times-circle'
    end
  end 
  
  def icon_color
    case self.etat
    when 'succès'
      'text-success'
    when 'echec', 
      'text-danger'
    when 'warning'
      'text-warning'
    end
  end
  
end
