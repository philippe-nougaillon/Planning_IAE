# ENCODING: UTF-8

class Intervenant < ApplicationRecord
	include PgSearch::Model
	multisearchable against: [:nom, :prenom, :titre1, :nom_du_status, :email]

	extend FriendlyId
	friendly_id :slug_candidates, use: :slugged
    
	audited
	
	has_many :cours
	has_many :formations, through: :cours
	has_many :responsabilites
	accepts_nested_attributes_for :responsabilites, 
									allow_destroy:true, 
									reject_if: lambda {|attributes| attributes['titre'].blank? || 
																	attributes['debut'].blank? ||
																	attributes['formation_id'].blank? ||
																	attributes['heures'].blank? }

	has_many :vacations
	has_many :dossiers
	has_many :invits

	validates :nom, :prenom, :status, presence: true
	validates :email, presence: true, format: Devise.email_regexp
	#validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP } 

	validates_uniqueness_of :email, case_sensitive: false

	normalizes :nom, with: -> nom { nom.strip }
	normalizes :prenom, with: -> prenom { prenom.strip }
	
	enum :status, [:CEV, :Permanent, :PR, :MCF, :MCF_HDR, :PAST, :PRAG, :Admin, :CEV_HSS, :CEV_ENS_C_CONTRACTUEL, :CEV_TIT_CONT_FP, :CEV_SAL_PRIV_IND]

	default_scope { order(:nom, :prenom) } 

	before_create :nom_with_underscore
	after_create :create_user_access

	def self.for_select
		{
			'Groupes (Doublons autorisés)' => where(doublon:true).map { |i| "#{i.nom} #{i.prenom}" },
			'Individus' => where("intervenants.doublon = ? OR intervenants.doublon is null", false).map { |i| "#{i.nom} #{i.prenom}"  }
		}
	end

	def self.liste_responsabilites
		["Direction de diplôme",
        "Gestion d'un groupe d'appentis M1",
        "Gestion d'un groupe d'appentis M2",
        "MAE encadrement de groupes FI & FC soirs/par groupe",
        "Encadrement des groupes FI jour",
        "Coordination d'une UE du MAE",
        "Coordination d'une UE thématique en MAE/1 groupe",
        "Coordination d'une UE thématique en MAE/2 groupes",
        "Organisation et accompagnement SPI",
        "Appel d'offre/appel à référencement/conception _ formation",
        "Développement formation inter/intra",
        "Coordination de projet de recherche international",
        "Participation à des salons",
        "Animation d'un groupe professionnel",
        "Chargé de mission",
        "Direction du laboratoire de recherche",
        "E-learning (conception, suivi, enregistrement)",
        "Direction de Chaire",
        "SCORE IAE message",
        "Co-rédaction d'un cas",
        "Coordination d'une UE (hors MAE)",
		"Coordination pédagogique en appui de la direction de programme (groupe > 40 étudiants à Paris)"
		]
	end
	

	def nom_prenom
		self.prenom.blank? ? self.nom.upcase : "#{self.nom} #{self.prenom}" 
	end

	def prenom_nom
		"#{self.try(:prenom)} #{self.nom}" 
	end

	def academ_nom
		"#{self.prenom.first}#{self.nom}"
	end

	def nom_du_status
		self.status
	end

	def nom_prenom_status
		self.prenom.blank? ? "#{self.nom.upcase} (#{self.status})" : "#{self.nom} #{self.prenom} (#{self.status})" 
	end

	def total_cours
		self.cours.where(etat:Cour.etats[:confirmé]).count
	end

	def self.xls_headers
		%w{Id Nom Prénom Email Statut Remise_dossier_srh Linkedin_url Titre1 Titre2 Spécialité Téléphone_fixe Téléphone_mobile Bureau Adresse CP Ville Créé_le Modifié_le Notifier? NbrHeuresCours}
	end

	def create_user_access
		new_password = SecureRandom.base64(12)
		# Création du compte d'accès (user) et envoi du mail de bienvenue
		user = User.new(role: "intervenant", nom: self.nom, prénom: self.prenom, email: self.email, mobile: self.téléphone_mobile, password: new_password)
		if user.valid?
			user.save
			title = "[PLANNING IAE Paris] Bienvenue !"
			mailer_response = IntervenantMailer.with(user: user, password: new_password, title: title).welcome_intervenant.deliver_now
			MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: user.email, subject: "Nouvel accès intervenant", title: title)
		end
	end

	def linked_user
    User.intervenant.or(User.enseignant).find_by("LOWER(users.email) = ?", self.try(:email).try(:downcase))
	end

	def permanent?
		['Permanent', 'PR','MCF','MCF_HDR','PRAG','PAST'].include?(self.status)
	end

	# Si c'est un examen IAE / examen rattrapage / Tiers-temps
  def examen?
		Intervenant.examens_ids.include?(self.id)
  end

	def self.examens_ids
		ENV["INTERVENANTS_EXAMENS"].split(',').map(&:to_i)
	end

	def self.sans_intervenant
		ENV["INTERVENANTS_PLACEHOLDER"].split(',').map(&:to_i)
	end

	def self.surveillants
		ENV["SURVEILLANTS_EXAMEN_IDS"].split(',').map(&:to_i)
	end

	def self.is_a_confirmer?
		self.id == Intervenant.a_confirmer_id
	end

	def self.a_confirmer_id
		ENV["A_CONFIRMER_ID"].to_i
	end

	def self.sans_dossier(début_période = '2025-09-01', fin_période = '2026-08-31')
		# Lister toutes les personnes ayant eu cours comme intervenant principal ou en binome

		# on garde les id des intervenants ayant eu cours sur la période
		intervenants_ids = Cour.where("DATE(cours.debut) BETWEEN ? AND ?", début_période, fin_période).pluck(:intervenant_id)
		# on y ajoute les intervenants ayants fait les cours comme binomes
		intervenants_ids += Cour.where("DATE(cours.debut) BETWEEN ? AND ?", début_période, fin_période).pluck(:intervenant_binome_id)
		# on ajoute les intervenants ayants fait des vacations
		intervenants_ids += Intervenant.where(id: Vacation.where("DATE(vacations.date) BETWEEN ? AND ?", début_période, fin_période).pluck(:intervenant_id))

		intervenants_avec_dossiers_sur_période = Dossier.where(période: AppConstants::PÉRIODE).pluck(:intervenant_id)

		Intervenant.where("id IN(?)", intervenants_ids.uniq)
								.where(status: ['CEV','CEV_ENS_C_CONTRACTUEL','CEV_TIT_CONT_FP','CEV_SAL_PRIV_IND'])
								.where.not(id: intervenants_avec_dossiers_sur_période)
								.uniq
	end

	def self.formation_for_select(intervenant_id)
		# Chercher les formations des examen
		examens_intervenant = Cour.where(intervenant_binome_id: intervenant_id).select{|cour| cour.examen?}
		formations_intervenant_from_examens = Formation.where(id: examens_intervenant.pluck(:formation_id))

		{
		  'Formations catalogue' => formations_intervenant_from_examens.where(hors_catalogue:false).not_archived.ordered.map { |i| i.nom }.uniq,
		  'Formations hors catalogue' => formations_intervenant_from_examens.where(hors_catalogue:true).not_archived.ordered.map { |i| i.nom }.uniq
		}
	end

	private
	# only one candidate for an nice id; one random UDID
	def slug_candidates
		[SecureRandom.uuid]
	end

	def nom_with_underscore
		self.nom = self.nom.gsub(" ","_")
	end
end