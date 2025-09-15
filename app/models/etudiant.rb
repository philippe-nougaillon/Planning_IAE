# Encoding: utf-8

class Etudiant < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  include PgSearch::Model
	multisearchable against: [:nom, :email, :mobile]

  audited
  
  validates :nom, :prénom, :civilité, presence: true
  # validates :nom, uniqueness: {scope: [:formation_id]}
  validates :email, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP } 
  
  belongs_to :formation

  before_destroy :delete_user

  has_many :attendances, dependent: :destroy
  has_many :justificatifs, dependent: :destroy

  scope :ordered, -> { order(:nom, :prénom) }

  workflow do
    state :prospect
    state :candidat
    state :étudiant
    state :diplomé
    state :non_diplomé
  end

  def self.xls_headers
    # [ 'id','Statut',
    #   'Civilité', 'NOM', 'NOM marital', 'Prénom', 'Date de naissance', 
    #   'Lieu de naissance', 'Pays de la ville de naissance', 'Nationalité',
    #   'Mail', 'Adresse', 'CP', 'Ville', 'Téléphone',
    #   'Dernier établmt fréquenté', 'Dernier diplôme obtenu', 'Catégorie "Science" diplôme', 
    #   'Numéro Sécurité sociale',
    #   'Numéro Apogée étudiant', 'Poste occupé', 
    #   'Nom Entreprise', 'Adresse entreprise', 'CP entreprise', 'Ville entreprise',
    #   'Formation_ID','Formation','created_at', 'updated_at'  
    # ]
    [ 'Civilité', 'NOM', 'Prénom', 'Mail', 'Mobile', 'Table']
  end

  def delete_user
    if u = User.étudiant.find_by(email: self.email)
      u.discard
    end
  end

  def nom_prénom
    self.nom + ' ' + self.prénom
  end

  def linked_user
    return User.étudiant.find_by("LOWER(users.email) = ?", self.try(:email).try(:downcase))
  end

  def self.for_select
		all.map { |i| "#{i.nom} #{i.prénom}"  }
	end
end
