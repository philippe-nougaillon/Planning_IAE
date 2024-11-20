class EtatLiquidatifCollectifIntervenantToXls < ApplicationService
  require 'spreadsheet'
  include ActionView::Helpers::NumberHelper
  attr_reader :cours

  def initialize(cours, intervenants, start_date, end_date, status)
    @cours = cours
    @intervenants = intervenants
    @start_date = start_date
    @end_date = end_date
    @status = status
  end

  def call    
    Spreadsheet.client_encoding = 'UTF-8'

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Etats de services'
		bold = Spreadsheet::Format.new :weight => :bold, :size => 10
    
    sheet.row(0).concat ['IAE PARIS']
    sheet.row(0).default_format = Spreadsheet::Format.new :weight => :bold, :size => 20
    sheet.row(1).concat ["ÉTAT LIQUIDATIF DES VACATIONS D'ENSEIGNEMENTS"]
    sheet.row(2).concat ["Décrets N°87-889 du 29/10/1987 et 88-994 du 18/10/1988 - CAr du 05/12/2023"]
    sheet.row(3).concat ["Du #{I18n.l @start_date.to_date} au #{I18n.l @end_date.to_date}. Statut : #{Intervenant.statuses.keys[@status.to_i]}"]

    sheet.row(5).concat ['Nom', 'Prénom','Formation', 'Intitulé', 'Code', 'Date','Heure','Etat',
      'Durée','HSS?','E-learning?','Binôme','CM/TD?', 'Taux_TD','HETD','Montant','Cumul_HETD','Dépassement']

    sheet.row(5).default_format = bold

    index = 6
    total_hetd = 0

    @intervenants.each do | intervenant |

      # Passe au suivant si intervenant est 'A CONFIRMER'
      next if intervenant.id == 445

      nbr_heures_statutaire = intervenant.nbr_heures_statutaire || 0

      cours_ids = @cours.where(intervenant: intervenant).order(:debut).pluck(:id)
      cours_ids << @cours.where(intervenant_binome: intervenant).pluck(:id)
      cours_ids = cours_ids.flatten

      @vacations = intervenant.vacations.where("date BETWEEN ? AND ?", @start_date, @end_date)
      @responsabilites = intervenant.responsabilites.where("debut BETWEEN ? AND ?", @start_date, @end_date)

      cumul_hetd = cumul_vacations = cumul_resps = cumul_tarif = cumul_duree = 0 
  
      cours_ids.each do |id|
          c = Cour.find(id)

          if c.imputable?
            cumul_hetd += c.duree.to_f * c.HETD
            montant_service = c.montant_service.round(2)
            cumul_tarif += montant_service
          end

          formation = Formation.unscoped.find(c.formation_id)

          fields_to_export = [
            # 'C',
            intervenant.nom,
            intervenant.prenom,
            formation.abrg, 
            c.nom_ou_ue,
            formation.code_analytique_avec_indice(c.debut), 
            I18n.l(c.debut.to_date),
            c.debut.strftime("%k:%M"), 
            c.etat,
            c.duree,
            (c.hors_service_statutaire ? "OUI" : ''),
            (c.elearning ? "OUI" : ''), 
            (c.intervenant && c.intervenant_binome ? "OUI" : ''),
            formation.nomtauxtd, 
            c.taux_td,
            c.HETD,
            montant_service,
            cumul_hetd,
            ((nbr_heures_statutaire > 0) && (cumul_hetd >= nbr_heures_statutaire) ? cumul_hetd - nbr_heures_statutaire : nil)
          ]

          sheet.row(index).replace fields_to_export
          index += 1
      end 

      # @vacations.each do |vacation|
      #   if vacation.vacation_activite
      #     intitulé = vacation.vacation_activite.nom
      #     tarif = vacation.vacation_activite.vacation_activite_tarifs.find_by(statut: VacationActiviteTarif.statuts[vacation.intervenant.status])
      #     if tarif && tarif.forfait_hetd
      #       cumul_hetd += tarif.forfait_hetd
      #     end
      #   end

      #   cumul_vacations += vacation.montant || 0

      #   formation = Formation.unscoped.find(vacation.formation_id)
        
      #   fields_to_export = [
      #         'V',
      #         intervenant.nom_prenom,
      #         I18n.l(vacation.date.to_date),
      #         nil,
      #         formation.nom,
      #         formation.code_analytique,
      #         intitulé || vacation.titre,
      #         nil, nil, 
      #         vacation.qte,
      #         nil, nil, nil, 
      #         'TD', 1,
      #         vacation.forfaithtd,
      #         vacation.montant,
      #         cumul_hetd,
      #         ((nbr_heures_statutaire > 0) && (cumul_hetd >= nbr_heures_statutaire) ? cumul_hetd - nbr_heures_statutaire : nil)
      #       ]
      #   sheet.row(index).replace fields_to_export
      #   index += 1
      # end

      # @responsabilites.each do |resp|
      #   montant_responsabilite = (resp.heures * Cour.Tarif).round(2)
      #   cumul_resps += montant_responsabilite
      #   cumul_hetd += resp.heures
      #   formation = Formation.unscoped.find(resp.formation_id)

      #   fields_to_export = [
      #         'R',
      #         intervenant.nom_prenom,
      #         I18n.l(resp.debut),
      #         nil,
      #         formation.nom,
      #         formation.code_analytique,
      #         resp.titre,
      #         nil,
      #         nil, 
      #         resp.heures, 
      #         nil, nil, nil,
      #         'TD', 1, nil,
      #         montant_responsabilite,
      #         cumul_hetd,
      #         ((nbr_heures_statutaire > 0) && (cumul_hetd >= nbr_heures_statutaire) ? cumul_hetd - nbr_heures_statutaire : nil)
      #   ]
      #   sheet.row(index).replace fields_to_export
      #   index += 1
      # end

      total = [
        # nil,
        "Ss Total #{intervenant.nom_prenom}",
        nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
        cumul_hetd,
        cumul_duree + cumul_tarif + cumul_vacations
      ]

      sheet.row(index).replace total
      sheet.row(index).default_format = bold
      index += 2
    end

    index += 5
    sheet.row(index).concat ["Fait à Paris le #{I18n.l(Date.today)}"]
    index += 5
    sheet.row(index).concat ['Barbara FITSCH-MOURAS']
    index += 1
    sheet.row(index).concat ['Responsable du service Formation et Développement']

    return book 
  end
end