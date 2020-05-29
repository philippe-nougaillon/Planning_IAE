class Fermeture < ApplicationRecord
	
	audited

	validates :date, presence: true
	validates :date, uniqueness: true
	
	default_scope { order(:date) } 

end
