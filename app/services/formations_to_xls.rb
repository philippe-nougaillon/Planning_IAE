class FormationsToXls < ApplicationService
  require 'spreadsheet'
  attr_reader :formations

  def initialize(formations)
    @formations = formations
  end

  def call
    Spreadsheet.client_encoding = 'UTF-8'
  
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Formations'
    bold = Spreadsheet::Format.new :weight => :bold, :size => 11

    headers = ["id", "nom", "promo", "diplome", "domaine", 
                "apprentissage",
                "nbr_etudiants",
                "nbr_heures",
                "abrg",
                "gestionnaire",
                "Mail de la formation",
                "code_analytique",
                "hors_catalogue",
                "archive",
                "hss",
                "memo",
                "created_at", "updated_at"]

    sheet.row(0).concat headers
    sheet.row(0).default_format = bold

    index = 1
    @formations.each do | formation |
        fields_to_export = [
          formation.id, 
          formation.nom,
          formation.promo,
          formation.diplome,
          formation.domaine,
          formation.apprentissage,
          formation.nbr_etudiants,
          formation.nbr_heures, 
          formation.abrg,
          formation.try(:user).try(:email),
          formation.courriel,
          formation.code_analytique,
          formation.hors_catalogue,
          formation.archive,
          formation.hss,
          formation.memo,
          formation.created_at, 
          formation.updated_at
        ]
        sheet.row(index).replace fields_to_export
        index += 1
    end

    return book

  end

end