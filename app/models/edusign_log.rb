class EdusignLog < ApplicationRecord
  belongs_to :user, optional: true

  enum :etat, {success: 0, 
              warning: 1, 
              error: 2, 
              }

  enum :modele_type, {
    'initialisation': 0,
    'synchronisation': 1,
    'synchronisation ponctuelle': 2,
    'salle changée': 3
  }

  def username
    user&.prénom_et_nom || "Serveur"
  end

  def icon_etat
    if self.etat == 'success'
      'check-circle'
    else
      'times-circle'
    end
  end 
  
  def icon_color
    case self.etat
    when 'success'
      'text-success'
    when 'warning'
      'text-warning'
    when 'error' 
      'text-error'
    end
  end

  def self.get_types
    ["Auto sync", "Manual sync", "Classroom changed"]
  end
end
