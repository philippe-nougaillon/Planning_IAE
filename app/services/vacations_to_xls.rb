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

    headers = ["intervenant.id",
                "intervenant.nom_prénom",
                "intervenant.statut",
                "formation.nom",
                "formation.apprentissage",
                "formation.nbr_etudiants",
                "formation.nbr_heures",
                "formation.abrg",
                "formation.gestionnaire",
                "formation.code_analytique (EOTP)",
                "vacation.date",
                "vacation.titre",
                "vacation.qte",
                "vacation.forfaithtd",
                "vacation.montant",
                "vacation.commentaires",
                "vacation.created_at",
                "vacation.updated_at"]

    sheet.row(0).concat headers
    sheet.row(0).default_format = bold

    index = 1
    @vacations.each do | vacation |
      next unless vacation.formation

      fields_to_export = [
        vacation.intervenant.try(:id),
        vacation.intervenant.try(:nom_prenom),
        vacation.intervenant.try(:status),
        vacation.formation.nom,
        vacation.formation.apprentissage,
        vacation.formation.nbr_etudiants,
        vacation.formation.nbr_heures, 
        vacation.formation.abrg,
        vacation.formation.user&.email,
        vacation.formation.code_analytique_avec_indice(vacation.date),
        vacation.date,
        vacation.titre,
        vacation.qte,
        vacation.forfaithtd,
        ActionController::Base.helpers.number_to_currency(vacation.montant),
        vacation.commentaires,
        vacation.created_at, 
        vacation.updated_at
      ]
      sheet.row(index).replace fields_to_export
      index += 1
    end

    return book

  end

end