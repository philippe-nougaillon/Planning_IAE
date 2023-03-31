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
	
  enum status: [:CEV, :Permanent, :PR, :MCF, :MCF_HDR, :PAST, :PRAG, :Admin, :CEV_HSS]

	default_scope { order(:nom, :prenom) } 

	before_create :nom_with_underscore
	# after_create :envoyer_mail
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
        "Coordination d'une UE (hors MAE)"]
    end
	

		def nom_prenom
		self.prenom.blank? ? self.nom.upcase : "#{self.nom} #{self.prenom}" 
	end

	def prenom_nom
		"#{self.try(:prenom)} #{self.nom}" 
	end

	def nom_du_status
		self.status
	end

	def total_cours
		self.cours.where(etat:Cour.etats[:confirmé]).count
	end

	def self.xls_headers
		%w{Id Nom Prénom Email Statut Remise_dossier_srh Linkedin_url Titre1 Titre2 Spécialité Téléphone_fixe Téléphone_mobile Bureau Adresse CP Ville Créé_le Modifié_le Notifier? NbrHeuresCours}
	end

	def self.generate_xls(intervenants, date_debut, date_fin)
		require 'spreadsheet'    
		
		Spreadsheet.client_encoding = 'UTF-8'
	
		book = Spreadsheet::Workbook.new
		sheet = book.create_worksheet name: 'Intervenants'
		bold = Spreadsheet::Format.new :weight => :bold, :size => 10
	
		sheet.row(0).concat Intervenant.xls_headers
		sheet.row(0).default_format = bold
		
		index = 1
		intervenants.each do |i|
			if date_debut.present?
				nbr_heures_cours = i.cours.where("debut BETWEEN (?) AND (?)", date_debut, date_fin).sum(:duree).to_f
			end

			fields_to_export = [
				i.id, 
				i.nom, 
				i.prenom, 
				i.email, 
				i.status, 
				i.remise_dossier_srh, 
				i.linkedin_url, 
				i.titre1, 
				i.titre2, 
				i.spécialité, 
				i.téléphone_fixe, 
				i.téléphone_mobile, 
				i.bureau, 
				i.adresse, 
				i.cp, 
				i.ville, 
				i.created_at, 
				i.updated_at,
				i.notifier?,
				nbr_heures_cours.present? ? nbr_heures_cours : nil
			]
			sheet.row(index).replace fields_to_export
			index += 1
		end
	
		return book
	end

	def create_user_access
		new_password = SecureRandom.hex(10)
		# Création du compte d'accès (user) et envoi du mail de bienvenue
		user = User.new(role: "intervenant", nom: self.nom, prénom: self.prenom, email: self.email, mobile: self.téléphone_mobile, password: new_password)
		if user.valid?
			user.save
			mailer_response = IntervenantMailer.with(user: user, password: new_password).welcome_intervenant.deliver_now
			MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: user.email, subject: "Nouvel accès intervenant")
		end
	end

	private
	def envoyer_mail
		if self.status == 'CEV' and self.doublon == false 
			IntervenantMailer.notifier_srh(self).deliver_later
		end
	end

	# only one candidate for an nice id; one random UDID
	def slug_candidates
		[SecureRandom.uuid]
	end

	def nom_with_underscore
		self.nom = self.nom.gsub(" ","_")
	end
end