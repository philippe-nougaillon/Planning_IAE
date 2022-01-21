# encoding: utf-8

class Salle < ApplicationRecord
	include Discard::Model

	audited
	
	has_many :cours

	default_scope { kept }	
	default_scope { order(:bloc, :nom) } 

	validates :nom, :places, presence: true
	validates :nom, uniqueness: true
	

	def self.salles_de_cours
		Salle.where("LENGTH(nom) = 2").where.not(nom: %w{A8 A20 D7 D8 D9})
	end

	def self.salles_de_cours_du_samedi
		self.salles_de_cours.where("nom like 'D%'")
	end

	def nom_places
		self.places.blank? ? self.nom : "#{self.nom} (#{self.places}P)" 
	end

	def self.nb_heures_journée
		return 6
	end

	def self.nb_heures_soirée
		return 3
	end

	def self.blocs
		self.all.pluck(:bloc).uniq.sort
	end

end
