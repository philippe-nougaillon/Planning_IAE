class Unite < ApplicationRecord
	include PgSearch::Model
	multisearchable against: [:nom, :num, :nom_formation],
                  if: lambda { |record| record.formation }

  belongs_to :formation

  def num_ue
  	"UE:#{ self.code }"
  end	

  def num_nom
  	"UE:#{ self.code } #{ self.nom }"
  end	

  def nom_formation
    self.formation.try(:nom)
  end

end
