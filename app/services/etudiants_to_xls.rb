class EtudiantsToXls < ApplicationService
  require 'spreadsheet'
  attr_reader :cours

  def initialize(etudiants)
    @etudiants = etudiants
  end

	def call
		Spreadsheet.client_encoding = 'UTF-8'

		book = Spreadsheet::Workbook.new
		sheet = book.create_worksheet name: 'Etudiants'
		bold = Spreadsheet::Format.new :weight => :bold, :size => 10

		sheet.row(0).concat [ 'Civilité','NOM', 'Prénom', 'Mail', 'Téléphone', 'Formation' ]
    sheet.row(0).default_format = bold
		
		index = 1

    @etudiants.each do |i|
      fields_to_export = [
				# i.id,
				# i.workflow_state,
				i.civilité,
				i.nom, 
				# i.nom_marital,
				i.prénom, 
				# i.date_de_naissance,
				# i.lieu_naissance,
				# i.pays_naissance,
				# i.nationalité,
				i.email, 
				# i.adresse,
				# i.cp,
				# i.ville,
				i.mobile,
				# i.dernier_ets,
				# i.dernier_diplôme,
				# i.cat_diplôme,
				# i.num_sécu,
				# i.num_apogée,
				# i.poste_occupé,
				# i.nom_entreprise,
				# i.adresse_entreprise,
				# i.cp_entreprise,
				# i.ville_entreprise,
				# i.formation_id,
				i.try(:formation).try(:nom), 
				# i.created_at, 
				# i.updated_at
      ]

			sheet.row(index).replace fields_to_export
			index += 1
		end
	
		return book
  end
end