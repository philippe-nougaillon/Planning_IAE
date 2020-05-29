# Encoding: utf-8

class Etudiant < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited
  
  validates :nom, :prénom, :civilité, presence: true
  # validates :nom, uniqueness: {scope: [:formation_id]}
  validates :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP } 
  
  belongs_to :formation

  workflow do
    state :prospect
    state :candidat
    state :étudiant
    state :diplomé
    state :non_diplomé
  end

  def self.xls_headers
    [ 'Civilité', 'NOM', 'NOM marital', 'Prénom', 'Date de naissance', 
      nil, nil, 
      'Lieu de naissance', 'Pays de la ville de naissance', 'Nationalité',
      'Mail', 'Adresse', 'CP', 'Ville', 'Téléphone',
      'Dernier établmt fréquenté', 'Dernier diplôme obtenu', 'Catégorie "Science" diplôme', 
      'Numéro Sécurité sociale',
      nil, nil, nil, 
      'Numéro Apogée étudiant', 'Poste occupé', 
      nil, 
      'Nom Entreprise', 'Adresse entreprise', 'CP entreprise', 'Ville entreprise'  
    ]
  end

	def self.generate_xls(etudiants)
    require 'spreadsheet'    
		
		Spreadsheet.client_encoding = 'UTF-8'
	
		book = Spreadsheet::Workbook.new
		sheet = book.create_worksheet name: 'Etudiants'
		bold = Spreadsheet::Format.new :weight => :bold, :size => 10

    sheet.row(0).concat ['id','Statut']
		sheet.row(0).concat Etudiant.xls_headers
    sheet.row(0).concat ['Formation_ID','Formation','created_at', 'updated_at']
    sheet.row(0).default_format = bold
		
		index = 1

    etudiants.each do |i|
      fields_to_export = [
          i.id,
          i.workflow_state,
          i.civilité,
          i.nom, 
          i.nom_marital,
          i.prénom, 
          i.date_de_naissance,
          nil,nil,
          i.lieu_naissance,
          i.pays_naissance,
          i.nationalité,
          i.email, 
          i.adresse,
          i.cp,
          i.ville,
          i.mobile,
          i.dernier_ets,
          i.dernier_diplôme,
          i.cat_diplôme,
          i.num_sécu,
          nil, nil, nil,
          i.num_apogée,
          i.poste_occupé,
          nil,
          i.nom_entreprise,
          i.adresse_entreprise,
          i.cp_entreprise,
          i.ville_entreprise,
          i.formation_id,
          i.try(:formation).try(:nom), 
          i.created_at, 
          i.updated_at
      ]

			sheet.row(index).replace fields_to_export
			index += 1
		end
	
		return book
  end
  
end
