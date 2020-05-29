# Encoding: utf-8

class ImportLogLine < ApplicationRecord
  belongs_to :import_log

  enum etat: [:succès, :echec]

  def icon_etat
    if self.etat == "succès"
      "glyphicon glyphicon-ok-circle text-success"
    else
      "glyphicon glyphicon-remove-circle text-danger"
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
