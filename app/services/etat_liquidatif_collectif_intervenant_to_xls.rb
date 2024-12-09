class EtatLiquidatifCollectifIntervenantToXls < ApplicationService
  require 'spreadsheet'
  include ActionView::Helpers::NumberHelper
  attr_reader :cours

  def initialize(start_date, end_date, status, cours_showed, vacations_showed, responsabilites_showed)
    @start_date = start_date
    @end_date = end_date
    @status = status
    @cours_showed = cours_showed
    @vacations_showed = vacations_showed
    @responsabilites_showed = responsabilites_showed
  end

  def call    
    Spreadsheet.client_encoding = 'UTF-8'

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Etats de services'
		bold = Spreadsheet::Format.new :weight => :bold, :size => 10
    
    sheet.row(0).concat ['IAE PARIS']
    sheet.row(0).default_format = Spreadsheet::Format.new :weight => :bold, :size => 20
    sheet.row(1).concat ["ÉTAT LIQUIDATIF DES VACATIONS D'ENSEIGNEMENTS. Du #{I18n.l @start_date.to_date} au #{I18n.l @end_date.to_date}. Statut : #{Intervenant.statuses.keys[@status.to_i]}"]
    sheet.row(1).default_format = bold
    sheet.row(2).concat ["Décrets N°87-889 du 29/10/1987 et 88-994 du 18/10/1988 - CAr du 05/12/2023"]
    sheet.row(3).concat ["Décret n°2024-951 du 23/10/2024 relatif au relèvement du salaire minimum de croissance"]
    sheet.row(4).concat ["Taux horaire en vigueur au 01/11/2024 : #{ Cour.taux_horaire_vacation }€"]

    sheet.row(6).concat ['Type d\'intervention', 'Nom', 'Prénom','Formation', 'Intitulé', 'Code EOTP', 'Destination Finan.', 'Date',
      'Durée en Hres','Binôme','Nbre d\'Hres CM', 'Nbre HTD', 'Taux TD','Mtnt total HTD']

    sheet.row(6).default_format = bold

    index = 7
    total_hetd = 0

    # Peupler la liste des intervenants ayant eu des cours en principal ou binome
    intervenant_ids = []

    if @cours_showed
      cours = Cour
                .where(etat: Cour.etats.values_at(:réalisé))
                .where("debut between ? and ?", @start_date, @end_date)
                .where.not(intervenant_id: 445)
    else
      cours = Cour.none
    end

    if @vacations_showed
      vacations = Vacation.where("date BETWEEN ? AND ?", @start_date, @end_date)
    else
      vacations = Vacation.none
    end

    if @responsabilites_showed
      responsabilites = Responsabilite.where("debut BETWEEN ? AND ?", @start_date, @end_date)
    else
      responsabilites = Responsabilite.none
    end

    intervenants = Intervenant.where(status: @status, id: [cours.pluck(:intervenant_id).uniq, vacations.pluck(:intervenant_id).uniq, responsabilites.pluck(:intervenant_id).uniq].flatten.uniq)

    intervenants.each do | intervenant |
      # Passe au suivant si intervenant est 'A CONFIRMER'
      next if intervenant.id == 445

      # nbr_heures_statutaire = intervenant.nbr_heures_statutaire || 0

      # Prendre que les cours / vacations / responsabilités parmi celles sélectionnés, qui sont liés à l'intervenant
      intervenant_cours = cours.where(intervenant_id: intervenant.id).or(cours.where(intervenant_binome_id: intervenant.id))
      intervenant_vacations = intervenant.vacations.where(id: vacations.pluck(:id), intervenant_id: intervenant.id)
      intervenant_responsabilites = intervenant.responsabilites.where(id: responsabilites.pluck(:id), intervenant_id: intervenant.id)

      cumul_hetd = cumul_vacations = cumul_responsabilites = cumul_tarif = cumul_cm = cumul_td = 0 

      intervenant_cours.each do |c|
        formation = Formation.unscoped.find(c.formation_id)

        if c.imputable?
          cumul_hetd += c.duree.to_f * c.HETD
          montant_service = c.montant_service.round(2)
          cumul_tarif += montant_service
          case formation.nomtauxtd
          when 'CM'
            cumul_cm += c.duree
            cumul_td += c.duree * 1.5
          when 'TD' then cumul_td += c.duree
          when '3xTD' then cumul_td += c.duree * 3
          end
        end

        fields_to_export = [
          'C',
          intervenant.nom,
          intervenant.prenom,
          formation.nom_promo_full, 
          c.nom_ou_ue,
          formation.code_analytique_avec_indice(c.debut), 
          formation.code_analytique.include?('DISTR') ? "101PAIE" : "102PAIE",
          I18n.l(c.debut.to_date),
          c.duree,
          (c.intervenant && c.intervenant_binome ? "OUI" : ''),
          # Jusqu'au dessus c'est bon
          *case formation.nomtauxtd
            when "CM" then [c.duree, c.duree * 1.5]
            when "TD", "3xTD" then [nil, c.duree]
            else [nil, nil]
          end,
          # Taux TD
          Cour.Tarif,
          # Mtnt total HTD
          montant_service
        ]

        sheet.row(index).replace fields_to_export
        index += 1
      end

      if intervenant_cours.any?
        total_cours = [
          "C",
          "#{ intervenant_cours.count } cours au total",
          nil,nil,nil,nil,nil,nil,nil,nil,
          cumul_cm, # Nbre hres CM
          cumul_td, # Nbre HTD
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

        formation = Formation.unscoped.find(vacation.formation_id)
        
        fields_to_export = [
          'V',
          intervenant.nom,
          intervenant.prenom,
          formation.nom_promo_full,
          intitulé || vacation.titre,
          formation.code_analytique_avec_indice(vacation.date),
          formation.code_analytique.include?('DISTR') ? "101PAIE" : "102PAIE",
          I18n.l(vacation.date),
          vacation.qte,
          nil,
          # Jusqu'au dessus c'est bon
          # Nbre d'Hres CM
          nil,
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
          nil, # Nbre hres CM
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
          resp.heures,
          nil,
          # Jusqu'au dessus c'est bon
          # Nbre d'Hres CM
          nil,
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
          nil, # Nbre hres CM
          nil, # Nbre HTD
          nil,
          cumul_responsabilites
        ]

        sheet.row(index).replace total_responsabilites
        sheet.row(index).default_format = bold
        index += 1
      end

      total = [
        "Total #{intervenant.nom_prenom}",
        nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
        cumul_tarif + cumul_vacations + cumul_responsabilites,
      ]

      sheet.row(index).replace total
      sheet.row(index).default_format = bold
      index += 2
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