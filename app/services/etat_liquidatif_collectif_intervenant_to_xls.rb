class EtatLiquidatifCollectifIntervenantToXls < ApplicationService
  require 'spreadsheet'
  include ActionView::Helpers::NumberHelper
  attr_reader :cours
  include DossiersHelper

  def initialize(start_date, end_date, statuses, is_cours_showed, is_vacations_showed, is_responsabilites_showed, is_dossiers_showed)
    @start_date = start_date
    @end_date = end_date
    @statuses = statuses
    @is_cours_showed = is_cours_showed
    @is_vacations_showed = is_vacations_showed
    @is_responsabilites_showed = is_responsabilites_showed
    @is_dossiers_showed = is_dossiers_showed
  end

  def call    
    Spreadsheet.client_encoding = 'UTF-8'

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Etats de services'
		bold = Spreadsheet::Format.new :weight => :bold, :size => 10
    
    sheet.row(0).concat ['IAE PARIS']
    sheet.row(0).default_format = Spreadsheet::Format.new :weight => :bold, :size => 20
    sheet.row(1).concat ["ÉTAT LIQUIDATIF DES VACATIONS D'ENSEIGNEMENTS. Du #{I18n.l @start_date.to_date} au #{I18n.l @end_date.to_date}. Statuts : #{Intervenant.statuses.keys.values_at(*Array(@statuses).map(&:to_i)).join(", ")}"]
    sheet.row(1).default_format = bold
    sheet.row(2).concat ["Décrets N°87-889 du 29/10/1987 et 88-994 du 18/10/1988 - CAr du 05/12/2023"]

    sheet.row(4).concat ['Type d\'intervention', 'Nom', 'Prénom','Formation', 'Intitulé', 'Code EOTP', 'Destination Finan.', 'Date', 'Nom Taux',
      'Durée en Hres','HeTD', 'Taux TD','Mtnt total HTD']

    sheet.row(4).default_format = bold

    index = 5
    total_hetd = 0

    # Peupler la liste des intervenants ayant eu des cours en principal ou binome
    intervenant_ids = []

    if @is_cours_showed
      cours = Cour
                .where(etat: Cour.etats.values_at(:réalisé))
                .where("debut between ? and ?", @start_date, @end_date)
                .where.not(intervenant_id: 445)
    else
      cours = Cour.none
    end

    if @is_vacations_showed
      vacations = Vacation.where("date BETWEEN ? AND ?", @start_date, @end_date)
    else
      vacations = Vacation.none
    end

    if @is_responsabilites_showed
      responsabilites = Responsabilite.where("debut BETWEEN ? AND ?", @start_date, @end_date)
    else
      responsabilites = Responsabilite.none
    end

    intervenants = Intervenant.where(status: @statuses, id: [cours.pluck(:intervenant_id).uniq, cours.pluck(:intervenant_binome_id).uniq, vacations.pluck(:intervenant_id).uniq, responsabilites.pluck(:intervenant_id).uniq].flatten.uniq)
    formations_par_eotp = Formation.includes(:cours).group_by(&:code_analytique)

    intervenants.each do | intervenant |
      # Passe au suivant si intervenant est 'A CONFIRMER'
      next if intervenant.id == 445

      # nbr_heures_statutaire = intervenant.nbr_heures_statutaire || 0

      # Prendre que les cours / vacations / responsabilités parmi celles sélectionnés, qui sont liés à l'intervenant
      intervenant_cours = cours.where(intervenant_id: intervenant.id).or(cours.where(intervenant_binome_id: intervenant.id)).includes(:formation)
      intervenant_vacations = intervenant.vacations.where(id: vacations.pluck(:id), intervenant_id: intervenant.id)
      intervenant_responsabilites = intervenant.responsabilites.where(id: responsabilites.pluck(:id), intervenant_id: intervenant.id)

      cumul_hetd = cumul_vacations = cumul_responsabilites = cumul_tarif = 0 

      # Affichage de l'état du/des dossier.s selon la période
      if @is_dossiers_showed
        @dossiers = Dossier.where(intervenant_id: intervenant.id, période: school_years_in_range(@start_date.to_date, @end_date.to_date))
        @dossiers.each do |dossier|
          fields_to_export = [
            'D',
            intervenant.nom,
            intervenant.prenom,
            dossier.période,
            dossier.workflow_state.humanize,
          ]

          sheet.row(index).replace fields_to_export
          index += 1
        end
      end


      # V2 : Liste des cours de l'intervenant groupés par code_eotp
      formations_par_eotp.each do |code_eotp, formation_group|
        ss_total_hetd = ss_total_tarif = 0
        any_cours_for_eotp = false

        intervenant_cours.select { |c| formation_group.map(&:id).include?(c.formation_id) }.each do |c|
          formation = formation_group.find { |f| f.id == c.formation_id }
          if c.imputable?            
            case formation.nomtauxtd
            when 'TD'
              montant_service = (c.duree.to_f * Cour.Tarif).round(2)
              ss_total_hetd += c.duree.to_f
            when '3xTD'
              montant_service = ((c.duree.to_f * 3) * Cour.Tarif).round(2)
              ss_total_hetd += c.duree.to_f * 3
            when 'CM'
              montant_service = ((c.duree.to_f * 1.5) * Cour.Tarif).round(2)
              ss_total_hetd += c.duree.to_f * 1.5
            else
              montant_service = 0
            end
            ss_total_tarif += montant_service
          end

          unless (montant_service.nil? || montant_service.zero?)
            any_cours_for_eotp ||= true

            fields_to_export = [
              'C',
              intervenant.nom,
              intervenant.prenom,
              # Ligne pour avoir plus d'informations, désactivation de la ligne à alterner au besoin avec celle encore en dessous
              # "#{formation.nom_promo_full} (nom taux td : #{formation.nomtauxtd}) [inputable : #{c.imputable?}] {hss? #{c.hors_service_statutaire || formation.hss}}",
              "#{formation.nom_promo_full}",
              c.nom_ou_ue,
              formation.code_analytique_avec_indice(c.debut),
              formation.code_analytique.include?('DISTR') ? "101PAIE" : "102PAIE",
              I18n.l(c.debut.to_date),
              formation.nomtauxtd,
              c.duree,
              *case formation.nomtauxtd
                when 'TD' then c.duree
                when '3xTD' then c.duree * 3
                when 'CM' then c.duree * 1.5
                else 0
              end,
              Cour.Tarif,
              montant_service
            ]

            sheet.row(index).replace fields_to_export
            index += 1
          end
        end
        
        if any_cours_for_eotp
          total_eotp = [
            "C",
            "Sous total code EOTP #{code_eotp || '???'} : #{intervenant_cours.select { |c| formation_group.map(&:id).include?(c.formation_id) }.count} cours",
            nil, nil, nil, nil, nil, nil, nil, nil,
            ss_total_hetd,
            Cour.Tarif,
            ss_total_tarif
          ]

          sheet.row(index).replace total_eotp
          sheet.row(index).default_format = bold
          index += 1
        end

        cumul_hetd += ss_total_hetd
        cumul_tarif += ss_total_tarif
      end

      # Total des cours de l'intervenant
      if intervenant_cours.any? && !cumul_tarif.zero?
        total_cours = [
          "C",
          "#{ intervenant_cours.count } cours au total",
          nil,nil,nil,nil,nil,nil,nil,nil,
          cumul_hetd, # Nbre HETD (ou HTD ou TD)
          Cour.Tarif,
          cumul_tarif
        ]

        sheet.row(index).replace total_cours
        sheet.row(index).default_format = bold
        index += 1
      end

      intervenant_vacations.each do |vacation|
        if vacation.vacation_activite
          intitulé = vacation.vacation_activite.nom
          tarif = vacation.vacation_activite.vacation_activite_tarifs.find_by(statut: VacationActiviteTarif.statuts[vacation.intervenant.status])
          if tarif && tarif.forfait_hetd
            cumul_hetd += tarif.forfait_hetd
          end
        end

        cumul_vacations += vacation.montant || 0

        formation = Formation.find(vacation.formation_id)
        
        fields_to_export = [
          'V',
          intervenant.nom,
          intervenant.prenom,
          formation.nom_promo_full,
          intitulé || vacation.titre,
          formation.code_analytique_avec_indice(vacation.date),
          formation.code_analytique.include?('DISTR') ? "101PAIE" : "102PAIE",
          I18n.l(vacation.date),
          nil,
          vacation.qte,
          # Jusqu'au dessus c'est bon
          # Nbre HTD
          nil,
          # Taux TD
          Cour.Tarif,
          # Mtnt total HTD
          vacation.montant,
        ]
        sheet.row(index).replace fields_to_export
        index += 1
      end

      if intervenant_vacations.any?
        total_vacations = [
          "V",
          "#{ intervenant_vacations.count } vacations au total",
          nil,nil,nil,nil,nil,nil,nil,nil,
          nil, # Nbre HTD
          nil,
          cumul_vacations
        ]

        sheet.row(index).replace total_vacations
        sheet.row(index).default_format = bold
        index += 1
      end

      intervenant_responsabilites.each do |resp|
        montant_responsabilite = (resp.heures * Cour.Tarif).round(2)
        cumul_responsabilites += montant_responsabilite
        cumul_hetd += resp.heures
        formation = Formation.unscoped.find(resp.formation_id)

        fields_to_export = [
          'R',
          intervenant.nom,
          intervenant.prenom,
          formation.nom_promo_full,
          resp.titre,
          formation.code_analytique_avec_indice(resp.debut),
          formation.code_analytique.include?('DISTR') ? "101PAIE" : "102PAIE",
          I18n.l(resp.debut),
          nil,
          resp.heures,
          # Jusqu'au dessus c'est bon
          # Nbre HTD
          resp.heures,
          # Taux TD
          Cour.Tarif,
          # Mtnt total HTD
          montant_responsabilite,
        ]
        sheet.row(index).replace fields_to_export
        index += 1
      end

      if intervenant_responsabilites.any?
        total_responsabilites = [
          "R",
          "#{ intervenant_responsabilites.count } responsabilités au total",
          nil,nil,nil,nil,nil,nil,nil,nil,
          nil, # Nbre HTD
          nil,
          cumul_responsabilites
        ]

        sheet.row(index).replace total_responsabilites
        sheet.row(index).default_format = bold
        index += 1
      end

      if !(cumul_tarif + cumul_vacations + cumul_responsabilites).zero?
        total = [
          "Total #{intervenant.nom_prenom}",
          nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
          cumul_tarif + cumul_vacations + cumul_responsabilites,
        ]

        sheet.row(index).replace total
        sheet.row(index).default_format = bold
        index += 2
      end
    end

    index += 3
    sheet.row(index).concat ["Fait à Paris le #{I18n.l(Date.today)}"]
    index += 3
    sheet.row(index).concat ['Eric LAMARQUE']
    index += 1
    sheet.row(index).concat ["Directeur de l'IAE Paris"]
    index += 3
    sheet.row(index).concat ['Barbara FITSCH-MOURAS']
    index += 1
    sheet.row(index).concat ['Responsable du service Formation et Développement']

    return book 
  end
end