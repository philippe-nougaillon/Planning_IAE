class Formation < ApplicationRecord
	include PgSearch::Model
	multisearchable against: [:nom]

	audited
	
	has_many :users
	has_many :cours, dependent: :destroy
	has_many :intervenants, through: :cours
	has_many :unites
	accepts_nested_attributes_for :unites, allow_destroy:true, 
									reject_if: lambda {|attributes| attributes['code'].blank?}
	has_many :etudiants
	accepts_nested_attributes_for :etudiants, allow_destroy:true, 
									reject_if: lambda {|attributes| attributes['nom'].blank?}
	has_many :vacations
	accepts_nested_attributes_for :vacations, allow_destroy:true, 
									reject_if: lambda {|attributes| attributes['intervenant_id'].blank? || 
																	attributes['titre'].blank? ||
																	attributes['date'].blank? ||
																	attributes['qte'].blank? ||
																	attributes['forfaithtd'].blank?	}
	belongs_to :user

	validates :nom, :nbr_etudiants, :nbr_heures, :abrg, presence: true
	validates :nom, uniqueness: { scope: :promo }
	
	default_scope { where("archive is null OR archive is false") }
	default_scope { order(:nom, :promo) } 
	
	def nom_promo
		self.promo.blank? ? self.nom : "#{self.nom} - #{self.promo}" 
	end

	def nom_promo_full
		self.promo.blank? ? self.nom : "#{self.nom} | Promo: #{self.promo}" 
	end

	# PAS UTILISÉE
	# def nom_promo_etudiants
	# 	self.promo.blank? ? "#{self.nom} (#{self.etudiants.count} ET.)"  : "#{self.nom} - #{self.promo} (#{self.etudiants.count} ET.)" 
	# end

	def nom_nbr_etudiants
		"#{ self.nom } (#{ self.calc_nbr_etudiants } ET.)" 
	end

	def nom_abrg_nbr_etudiants
		"#{ self.abrg } (#{ self.calc_nbr_etudiants } ET.)" 
	end

	def calc_nbr_etudiants
		self.etudiants.count > 0 ? self.etudiants.count : self.nbr_etudiants
	end

	def nom_eotp
		self.code_analytique.blank? ? self.nom : "#{self.nom} -> #{self.code_analytique}"
	end

	def code_analytique_avec_indice(date)
		code = self.code_analytique || ''
		if code.last == '?'
			indice = ((date.year - self.cours.first.debut.year) + 1)
			# renvoie '_' si l'indice dépasse la limite de 3 années (cursus normal)
			return code.gsub('?', indice <= 3 ? indice.to_s : '_')
		else
			return code
		end
	end

	def self.for_select
		{
		  'Formations catalogue' => where(hors_catalogue:false).map { |i| i.nom },
		  'Formations hors catalogue' => where(hors_catalogue:true).map { |i| i.nom }
		}
	end

	def positive_color
		if self.color == '#000000'
			'#EBEBEB'
		else
			self.color
		end
	end

	# Pour savoir si cette formation est gérée par un partenaire QSE
	def partenaire_qse?
		%w[M1QSE M2QSE].include?(self.abrg[0..4])
	end

	def self.cobayes_émargement
		[258, 599, 671, 672, 683, 687]
	end

end

