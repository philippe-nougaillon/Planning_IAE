class NouvelExportCoursToXls < ApplicationService
  require 'spreadsheet'
  attr_reader :cours

  def initialize(cours, exporter_binome = false)
    @cours = cours
    @exporter_binome = exporter_binome
  end

  def call
    Spreadsheet.client_encoding = 'UTF-8'

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Export Enseignants'
    bold = Spreadsheet::Format.new :weight => :bold, :size => 10
    
    headers = [
      "Date de début", 
      "Heure de début", 
      "Formation",
      "Nombre étudiants",
      "Intervenant", 
      "Statut"
    ]
    headers += ["Intervenant binôme","Statut binôme"] if @exporter_binome

    sheet.row(0).concat headers
    sheet.row(0).default_format = bold
    
    index = 1
    cours.each do |c|
      formation = Formation.find(c.formation_id)
      
      fields_to_export = [
        I18n.l(c.debut.to_date),
        c.debut.to_formatted_s(:time),
        formation.nom,
        formation.nbr_etudiants,
        c.intervenant&.nom_prenom,
        c.intervenant&.status
      ]

      if c.intervenant_binome
        fields_to_export += [c.intervenant_binome.nom_prenom , c.intervenant_binome.status]
      end
      
      sheet.row(index).replace fields_to_export
      index += 1
    end

    return book
  end
end