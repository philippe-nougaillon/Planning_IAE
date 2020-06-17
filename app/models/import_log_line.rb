# Encoding: utf-8

class ImportLogLine < ApplicationRecord
  belongs_to :import_log

  enum etat: [:succès, :echec]

  def icon_etat
    if self.etat == 'succès'
      'check-circle'
    else
      'times-circle'
    end
  end

  def icon_color
    if self.etat == 'succès'
      'text-success'
    else  
      'text-danger'
    end
  end

  def pretiffy_message   
  	if self.message.include?('||')	
      [self.message.split('|| ERREURS:').first, self.message.split('|| ERREURS:').last]
    else
      [self.message, nil]
    end
  end	

end
