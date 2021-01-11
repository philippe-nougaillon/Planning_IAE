class Fermeture < ApplicationRecord
	
	audited

	validates :date, :nom, presence: true
	validates :date, uniqueness: true
	
	#default_scope { order('updated_at DESC, date DESC') } 

end
