# Encoding: UTF-8

class User < ApplicationRecord
  include Discard::Model

  include PgSearch::Model
	multisearchable against: [:nom, :email]
  
  audited
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :rememberable and :omniauthable,
  devise :database_authenticatable,
         :recoverable, :trackable, :validatable, :registerable, :timeoutable

  belongs_to :formation, optional: true   
  has_many :notes

  validates :nom, :prénom, :role, presence: true    

  enum :role, {étudiant: 0, 
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
    "
    #{self.email.split('@').first}
    (#{self.role.humanize})
    "
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

  def nom_prénom_role
    "#{self&.nom&.upcase} #{self&.prénom&.humanize} (#{self.role.upcase})"
  end

  # wish for discarded users to be unable to login and stop their session
  def active_for_authentication?
    super && !self.discarded?
  end

  def role_number
    User.roles[self.role]
  end

  def self.xls_headers
    [ 'nom','prénom','email', 'mobile', 'rôle' ]
  end

  # Pour donner le role 'gestionnaire' à un partenaire
  # qui pourra modifier que les cours de ses formations
  def partenaire_qse?
    ["d.gbedemah@icp.fr","m.danet@icp.fr"].include?(self.email)
  end

  def unlinked?
    return ( self.étudiant? && Etudiant.find_by("LOWER(etudiants.email) = ?", self.email.downcase).nil? ) || ( (self.intervenant? || self.enseignant?) && Intervenant.find_by("LOWER(intervenants.email) = ?", self.email.downcase).nil? )
  end

  def accueil_vacataire?
    self.email == "vacaccueil@iae.pantheonsorbonne.fr"
  end

  def self.for_edusign_logs_select
    users = User.where(id: EdusignLog.pluck(:user_id)).map { |u| [u.prénom_et_nom, u.id] }
    users << ["Serveur", 0]
    users.sort
  end

  def super_admin?
    ENV['USER_JOBS_AUTHORIZATION_IDS']
      .to_s
      .split(',')
      .map(&:to_i)
      .include?(id)
  end

  private

    def timeout_in
      self.étudiant? ? 4.hours : 24.hours
    end
end
