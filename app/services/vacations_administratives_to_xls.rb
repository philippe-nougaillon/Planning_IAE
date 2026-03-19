class VacationsAdministrativesToXls < ApplicationService
  require 'spreadsheet'
  # attr_reader :vacations

  def initialize(examens, start_date, end_date)
    @examens = examens
    @start_date = start_date
    @end_date = end_date
    @cumuls = {}
    @taux_horaire = Cour.taux_horaire_vacation
  end

  def call
    Spreadsheet.client_encoding = 'UTF-8'
  
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Vacations'
    bold = Spreadsheet::Format.new :weight => :bold, :size => 11

    headers = ['Date', 'Type', 'Formation', 'Centre de coût', 'Destination financière', 'EOTP', 'Total heures']

    sheet.row(0).concat headers
    sheet.row(0).default_format = bold

    index = 1

    surveillants_name = []

    @examens.each do | exam |
      exam.commentaires.split('[').each do |item|
        if !item.blank?
          surveillant_item = item.gsub(']', '').delete("\r\n\\")
          surveillants_name << surveillant_item if !surveillants_name.include?(surveillant_item)
        end
      end
    end

    surveillants_name.sort.each do | surveillant_name |
      cumul_durée = 0

      fields_to_export = [surveillant_name]
      sheet.row(index).replace fields_to_export
      index += 1

      @examens.each do | exam |
        exam.commentaires.split('[').each do |item|
          unless item.blank?
            surveillant_item = item.gsub(']', '').delete("\r\n\\")
            if surveillant_item == surveillant_name
              durée = exam.duree + ((exam.intervenant_id == 1314) ? 0 : 1)
              is_vacataire = (exam.intervenant_id == 1314)
              cumul_durée += durée

              # ['Date', 'Type', 'Formation', 'Centre de coût', 'Destination financière', 'EOTP', 'Total heures']
              fields_to_export = [
                I18n.l(exam.debut, format: :long),
                is_vacataire ? "Vacataire" : "Surveillance Examen",
                exam.formation.nom_promo,
                '7322GRH',
                (exam.formation.diplome.upcase == 'LICENCE' ? '101PAIE' : exam.intervenant.id == 1314 ? '115PAIE' : '102PAIE'),
                exam.formation.code_analytique_avec_indice(exam.debut).gsub('HCO','VAC'),
                durée
              ]
              sheet.row(index).replace fields_to_export
              index += 1
            end
          end
        end
      end

      fields_to_export = [
        nil,
        nil,
        nil,
        nil,
        nil,
        "Total heures :",
        cumul_durée
      ]
      sheet.row(index).replace fields_to_export
      index += 1

      fields_to_export = [
        nil,
        nil,
        "Taux horaire en vigueur au 01/01/2026 :", 
        "#{ @taux_horaire } €",
        nil,
        "Total brut :",
        "#{ cumul_durée * @taux_horaire } €"]

      sheet.row(index).replace fields_to_export
      index += 2

    end

    return book

  end

end