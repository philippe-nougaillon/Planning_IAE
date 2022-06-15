class VacationsToXls < ApplicationService
  require 'spreadsheet'
  attr_reader :vacations

  def initialize(vacations)
    @vacations = vacations
  end

  def call
    Spreadsheet.client_encoding = 'UTF-8'
  
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Vacations'
    bold = Spreadsheet::Format.new :weight => :bold, :size => 11

    headers = ["formation.id",
                "vacation.formation.nom",
                "vacation.id",
                "vacation.date",
                "vacation.intervenant",
                "vacation.titre",
                "vacation.qte",
                "vacation.forfaithtd",
                "vacation.commentaires",
                "vacation.created_at",
                "vacation.updated_at",
                "formation.promo",
                "formation.diplome",
                "formation.domaine", 
                "formation.apprentissage",
                "formation.nbr_etudiants",
                "formation.nbr_heures",
                "formation.abrg",
                "formation.gestionnaire",
                "formation.Mail de la formation",
                "formation.code_analytique",
                "formation.hors_catalogue",
                "formation.archive",
                "formation.hss",
                "formation.memo"]

    sheet.row(0).concat headers
    sheet.row(0).default_format = bold

    index = 1
    @vacations.each do | vacation |
        next unless vacation.formation
        fields_to_export = [
          vacation.formation.id, 
          vacation.formation.nom,
          vacation.id,
          vacation.date,
          vacation.try(:intervenant).nom_prenom,
          vacation.titre,
          vacation.qte,
          vacation.forfaithtd,
          vacation.commentaires,
          vacation.created_at, 
          vacation.updated_at,
          vacation.formation.promo,
          vacation.formation.diplome,
          vacation.formation.domaine,
          vacation.formation.apprentissage,
          vacation.formation.nbr_etudiants,
          vacation.formation.nbr_heures, 
          vacation.formation.abrg,
          vacation.formation.try(:user).try(:email),
          vacation.formation.courriel,
          vacation.formation.code_analytique,
          vacation.formation.hors_catalogue,
          vacation.formation.archive,
          vacation.formation.hss,
          vacation.formation.memo
          
        ]
        sheet.row(index).replace fields_to_export
        index += 1
    end

    return book

  end

end