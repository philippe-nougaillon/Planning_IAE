class CoursToXls < ApplicationService
  require 'spreadsheet'
  attr_reader :cours

  def initialize(cours, exporter_binome, voir_champs_privés = false)
    @cours = cours
    @exporter_binome
    @voir_champs_privés = voir_champs_privés
  end

  def call
    Spreadsheet.client_encoding = 'UTF-8'

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Planning'
		bold = Spreadsheet::Format.new :weight => :bold, :size => 10
	
    sheet.row(0).concat Cour.xls_headers
		sheet.row(0).default_format = bold
    
    index = 1
    cours.each do |c|
      formation = Formation.unscoped.find(c.formation_id)
      fields_to_export = [
        c.id, 
        I18n.l(c.debut.to_date), 
        c.debut.to_formatted_s(:time), 
        I18n.l(c.fin.to_date), 
        c.fin.to_formatted_s(:time), 
        c.formation_id, formation.nom_promo, formation.code_analytique, 
        c.intervenant_id, c.intervenant.nom_prenom,
        c.intervenant_binome.try(:nom_prenom), 
        c.code_ue, c.nom, 
        c.etat, (c.salle ? c.salle.nom : nil), 
        c.duree,
        (c.elearning ? "OUI" : nil), 
        (!(c.imputable?) ? "OUI" : nil),
        ((@voir_champs_privés && c.imputable?) ? formation.taux_td : nil),
        ((@voir_champs_privés && c.imputable?) ? c.HETD : nil),
        (@voir_champs_privés ? c.commentaires : nil),
        c.created_at,
        c.audits.first.user.try(:email),
        c.updated_at
      ]
      sheet.row(index).replace fields_to_export
      #logger.debug "#{index} #{fields_to_export}"
      index += 1

      # créer une ligne d'export supplémentaire pour le cours en binome
      if @exporter_binome and c.intervenant_binome
        fields_to_export[8] = c.intervenant_binome_id
        fields_to_export[9] = c.intervenant_binome.nom_prenom 
        sheet.row(index).replace fields_to_export
        index += 1
      end  
    end

    return book
  end
end