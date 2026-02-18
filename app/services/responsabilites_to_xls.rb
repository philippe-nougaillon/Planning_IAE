class ResponsabilitesToXls < ApplicationService
  require 'spreadsheet'
  attr_reader :responsabilites

  def initialize(responsabilites)
    @responsabilites = responsabilites
  end

  def call
    Spreadsheet.client_encoding = 'UTF-8'
  
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Responsabilites'
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
                "responsabilite.date",
                "responsabilite.titre",
                "responsabilite.heures",
                "responsabilite.commentaires",
                "responsabilite.created_at",
                "responsabilite.updated_at"]

    sheet.row(0).concat headers
    sheet.row(0).default_format = bold

    index = 1
    @responsabilites.each do | responsabilite |
      next unless responsabilite.formation

      fields_to_export = [
        responsabilite.intervenant.try(:id),
        responsabilite.intervenant.try(:nom_prenom),
        responsabilite.intervenant.try(:status),
        responsabilite.formation.nom,
        responsabilite.formation.apprentissage ? "OUI" : "NON",
        responsabilite.formation.nbr_etudiants,
        responsabilite.formation.nbr_heures, 
        responsabilite.formation.abrg,
        responsabilite.formation.user&.email,
        responsabilite.formation.code_analytique_avec_indice(responsabilite.debut),
        responsabilite.debut,
        responsabilite.titre,
        responsabilite.heures,
        responsabilite.commentaires,
        I18n.l(responsabilite.created_at, format: :long), 
        I18n.l(responsabilite.updated_at, format: :long)
      ]
      sheet.row(index).replace fields_to_export
      index += 1
    end

    return book

  end

end