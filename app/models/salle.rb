# encoding: utf-8

class Salle < ApplicationRecord
	include Discard::Model

	audited
	
	has_many :cours

	default_scope { kept }	
	default_scope { order(:bloc, :nom) } 

	validates :nom, :bloc, :places, presence: true
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

	def nom_places_block_desc
		"#{self.nom} - Bat #{self.bloc} #{"-> #{description_ponscarme}" if self.bloc == "P" && description_ponscarme} (#{self.places}P)"
	end

	def description_ponscarme
		case self.nom
		when "2.1"
			"Salle de cours mobile"
		when "2.2"
			"Salle de cours serpentine"
		when /^(\d|\w{3}\.\d)$/
			"Salle de cours"
		when /^\d\.\w$/
			"Salle de réunion"
		when /^\d{3}$/
			"Bureau"
		end
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
