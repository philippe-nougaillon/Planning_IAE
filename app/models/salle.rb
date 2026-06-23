# encoding: utf-8

class Salle < ApplicationRecord
	include Discard::Model

	audited
	
	has_many :cours

	default_scope { kept }	
	default_scope { order(:bloc, :nom) } 

	scope :ponscarme_et_blocZ , -> { where(bloc: ['P','Z']) }
	# TODO : modifier ou remplacer le scope bureaux_profs en utilisant la fonction "description_ponscarme"
	scope :bureaux_profs, -> { where(nom: ['300','300.A','300.B','301','301.A','301.B','302','302.A','302.B','303','303.A','303.B','304','304.A','304.B','305','305.A','305.B'])}
	scope :salles_non_reservables_intervenants, -> { where(id: ENV.fetch('SALLES_NON_RESERVABLES_INTERVENANTS_IDS', '').split(',').map(&:strip)) }

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
		"#{self.nom}#{" -> #{description_ponscarme}" if self.bloc == "P" && description_ponscarme} (#{self.places}P)"
	end

	def description_ponscarme
		case self.nom
		when "2.1"
			"Salle de cours mobile"
		when "2.2"
			"Salle de cours serpentine"
		when "2.4"
			"Salle de cours tables hautes"
		when /^(\d\.\d)$/, /^(\w{3}\.\d)$/ # Ex: 1.1 ou RDJ.1
			"Salle de cours"
		when /^\d\.\w$/ # Ex: 2.A
			"Salle de réunion"
		when /^\d{3}\.?\w*$/ # Ex: 300, 300.A, 302B
			"Bureau enseignant"
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

	# Retourne le nom des salles zoom
	def self.liste_salles_zoom
		["ZOOM 1", "ZOOM 2"]
	end

	def self.for_select
		self.all
				.group_by{|s| s.description_formated_for_group_by }
				# Transform_values permet de modifier la valeur de chaque clé (valeur représentant une liste de salles) en map [nom_places_block_desc, id]
				.transform_values { |salles| 
					salles.map { |salle| 
						[salle.nom_places_block_desc, salle.id] 
					} 
				}
	end

	# Retourne la description appropriée pour le group_by
	def description_formated_for_group_by
		description = self.description_ponscarme

		if /^Salle de cours.*$/.match(description)
			"Salle de cours"
		else
			description || "Accueil"
		end
	end
end
