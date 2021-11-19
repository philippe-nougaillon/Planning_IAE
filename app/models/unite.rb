class Unite < ApplicationRecord
	include PgSearch::Model
	multisearchable against: [:nom, :num, :nom_formation]

  belongs_to :formation

  def num_nom
  	self.num + ":" + self.nom
  end	

  def nom_formation
    self.formation.try(:nom)
  end

end
