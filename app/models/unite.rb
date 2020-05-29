class Unite < ApplicationRecord

  belongs_to :formation

  def num_nom
  	self.num + ":" + self.nom
  end	

end
