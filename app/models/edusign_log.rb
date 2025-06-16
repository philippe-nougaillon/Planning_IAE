class EdusignLog < ApplicationRecord
  belongs_to :user, optional: true

  enum etat: {succès: 0, 
              warning: 1, 
              échec: 2, 
              }

  def username
    user&.username || "Serveur"
  end

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
    when 'échec', 
      'text-error'
    when 'warning'
      'text-warning'
    end
  end
end
