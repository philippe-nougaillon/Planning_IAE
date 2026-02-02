class ExportCacToXls < ApplicationService
  require 'spreadsheet'
  include ActionView::Helpers::NumberHelper
  attr_reader :cours

  def initialize(période)
    @période = période
  end

  def call    
    Spreadsheet.client_encoding = 'UTF-8'

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Export CAC'
		bold = Spreadsheet::Format.new :weight => :bold, :size => 10

    sheet.row(0).concat ['IAE PARIS']
    sheet.row(0).default_format = Spreadsheet::Format.new :weight => :bold, :size => 20
    sheet.row(1).concat ["Export CAC. Période #{@période}"]
    sheet.row(1).default_format = bold
    # sheet.row(2).concat ["Décrets N°87-889 du 29/10/1987 et 88-994 du 18/10/1988 - CAr du 05/12/2023"]

    sheet.row(4).concat ['Intervenant', 'Nombre d\'heures cours', 'Montant total vacations', 'État dossier', 'Dossier validé ?']
    sheet.row(4).default_format = bold

    index = 5
    total_hetd = 0

    début_période, fin_période = Dossier.dates_début_fin_année_scolaire(@période)

    intervenants_ids = Cour.where("DATE(cours.debut) BETWEEN ? AND ?", début_période, fin_période).where(etat: Cour.etats.values_at(:réalisé)).pluck(:intervenant_id, :intervenant_binome_id).flatten
    intervenants_ids += Intervenant.where(id: Vacation.where("DATE(vacations.date) BETWEEN ? AND ?", début_période, fin_période).pluck(:intervenant_id))

    intervenants = Intervenant.where(id: intervenants_ids.uniq)
								.where(status: ['CEV','CEV_ENS_C_CONTRACTUEL','CEV_TIT_CONT_FP','CEV_SAL_PRIV_IND'])
								.uniq

    intervenants.each do |intervenant|
      cumul_vacations = 0
      cours = intervenant.cours.where(etat: Cour.etats.values_at(:réalisé)).where("DATE(cours.debut) BETWEEN ? AND ?", début_période, fin_période)
      vacations = intervenant.vacations.where("date BETWEEN ? AND ?", début_période, fin_période)
      dossier = intervenant.dossiers.find_by(période: @période)

      fields_to_export = [
        intervenant.nom_prenom,
        cours.sum('duree'),
        vacations.sum('montant'),
        dossier&.workflow_state || "pas de dossier",
        ["validé","archivé"].include?(dossier&.workflow_state) ? "OUI" : "NON"
      ]

      sheet.row(index).replace fields_to_export
      index += 1
    end

    index += 5
    sheet.row(index).concat ["Fait à Paris le #{I18n.l(Date.today)}"]

    return book 
  end
end