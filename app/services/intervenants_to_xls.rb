class IntervenantsToXls < ApplicationService
  require 'spreadsheet'
  attr_reader :cours

  def initialize(intervenants, date_debut, date_fin)
    @intervenants = intervenants
    @date_debut = date_debut
    @date_fin = date_fin
  end

	def call
		Spreadsheet.client_encoding = 'UTF-8'

		book = Spreadsheet::Workbook.new
		sheet = book.create_worksheet name: 'Intervenants'
		bold = Spreadsheet::Format.new :weight => :bold, :size => 10

		sheet.row(0).concat Intervenant.xls_headers
		sheet.row(0).default_format = bold

    index = 1
		@intervenants.each do |i|
			if @date_debut.present? && @date_fin.present?
				cours = i.cours.where("debut BETWEEN ? AND ?", @date_debut, @date_fin)
			elsif @date_debut.present?
				cours = i.cours.where("debut > ?", @date_debut)
			elsif @date_fin.present?
				cours = i.cours.where("debut < ?", @date_fin)
			else
				cours = i.cours
			end
			nbr_heures_cours = cours.sum(:duree).to_f

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
				nbr_heures_cours
			]
			sheet.row(index).replace fields_to_export
			index += 1
		end

		return book
	end
end