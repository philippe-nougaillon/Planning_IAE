class CoursAcademToXls < ApplicationService
  require 'spreadsheet'
  attr_reader :cours

  def initialize(cours)
    @cours = cours
  end

  def call  
    Spreadsheet.client_encoding = 'UTF-8'

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Planning'
    bold = Spreadsheet::Format.new :weight => :bold, :size => 10

    headers = %w{EVT_codunic EVT_date EVT_fac1 EVT_prgm EVT_ue EVT_type EVT_stat EVT_idbda EVT_nbheur EVT_nbetu EVT_campus EVT_pace EVT_section EVT_session EVT_deliveryMode}

    sheet.row(0).concat headers
    sheet.row(0).default_format = bold

    index = 1
    @cours.each do |c|
      formation = Formation.find(c.formation_id)
      fields_to_export = [
        c.id, 
        I18n.l(c.debut.to_date),
        c.intervenant.academ_nom,
        formation.abrg,
        c.code_ue,
        "C", 
        "R",
        nil,
        c.intervenant_binome_id ? (c.duree / 2).to_s : c.duree.to_s,
        formation.calc_nbr_etudiants,
        "Paris",
        "PT",
        nil,
        nil,
        nil
      ]
      sheet.row(index).replace fields_to_export
      #logger.debug "#{index} #{fields_to_export}"
      index += 1
    end

    return book
  end
end