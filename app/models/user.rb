# Encoding: UTF-8

class User < ApplicationRecord
  include Discard::Model

  include PgSearch::Model
	multisearchable against: [:nom, :email]
  
  audited
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable :registerable,
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :formation, optional: true   

  validates :nom, :prénom, :role, presence: true    

  enum role: {étudiant: 0, 
              intervenant: 1, 
              enseignant: 2, 
              accueil: 3, 
              rh: 4, 
              gestionnaire: 5,
              administrateur: 6 }

  default_scope { order(:nom) } 

  def admin?
    self.role == 'administrateur'
  end

  def reserver?
    false
  end

  def username 
    "#{self.email.split('@').first} (#{self.role})"
  end

  def isRHGroupMember?
    self.rh?
  end

  def nom_et_prénom
    "#{self.nom.upcase if self.nom} #{self.prénom.upcase if self.prénom}"
  end 

  def prénom_et_nom
		"#{self.try(:prénom)} #{self.try(:nom)}" 
  end

  # wish for discarded users to be unable to login and stop their session
  def active_for_authentication?
    super && !discarded?
  end

  def role_number
    User.roles[self.role]
  end

  def self.xls_headers
    [ 'nom','prénom','email', 'mobile', 'rôle' ]
  end

end
