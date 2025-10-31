class EtatLiquidatifCollectifFormationToXls < ApplicationService
  require 'spreadsheet'
  include ActionView::Helpers::NumberHelper
  attr_reader :cours

  def initialize(start_date, end_date, statuses, cours_showed, vacations_showed, responsabilites_showed)
    @start_date = start_date
    @end_date = end_date
    @statuses = statuses
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
    sheet.row(1).concat ["ÉTAT LIQUIDATIF DES VACATIONS D'ENSEIGNEMENTS. Du #{I18n.l @start_date.to_date} au #{I18n.l @end_date.to_date}. Statuts : #{Intervenant.statuses.keys.values_at(*Array(@statuses).map(&:to_i)).join(", ")}"]
    sheet.row(1).default_format = bold
    sheet.row(2).concat ["Décrets N°87-889 du 29/10/1987 et 88-994 du 18/10/1988 - CAr du 05/12/2023"]

    sheet.row(4).concat ['Type d\'intervention', 'Nom', 'Prénom','Formation', 'Intitulé', 'Code EOTP', 'Destination Finan.', 'Date',
      'Durée en Hres','Binôme','Nbre d\'Hres CM', 'Nbre HTD', 'Taux TD','Mtnt total HTD']

    sheet.row(4).default_format = bold

    index = 5
    total_hetd = 0

    if @cours_showed
      cours = Cour
                .where(etat: Cour.etats.values_at(:réalisé))
                .where("debut between ? and ?", @start_date, @end_date)
                .where.not(intervenant_id: Intervenant.a_confirmer_id)
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

    formations = Formation.not_archived.where(id: [cours.pluck(:formation_id).uniq, vacations.pluck(:formation_id).uniq, responsabilites.pluck(:formation_id).uniq].flatten.uniq).ordered
    formations.each do | formation |
      any_cours = false
      
      cumul_hetd = cumul_vacations = cumul_responsabilites = cumul_tarif = cumul_cm = cumul_td = 0

      # Chercher la liste des intervenants qui ont eu un cours / vacation / responsabilité lié à la formation
      intervenant_ids = []
      if @cours_showed
        intervenant_ids << cours.where(formation_id: formation.id).distinct(:intervenant_id).pluck(:intervenant_id)
        intervenant_ids << cours.where(formation_id: formation.id).distinct(:intervenant_binome_id).pluck(:intervenant_binome_id)
      end
      
      if @vacations_showed
        intervenant_ids << vacations.where(formation_id: formation.id).distinct(:intervenant_id).pluck(:intervenant_id)
      end

      if @responsabilites_showed
        intervenant_ids << responsabilites.where(formation_id: formation.id).distinct(:intervenant_id).pluck(:intervenant_id)
      end
      
      intervenants = Intervenant.where(id: intervenant_ids.flatten.compact, status: @statuses)

      intervenants.each do |intervenant|
        # Passe au suivant si intervenant est 'A CONFIRMER'
        next if intervenant.is_a_confirmer?

        # nbr_heures_statutaire = intervenant.nbr_heures_statutaire || 0

        # Prendre que les cours / vacations / responsabilités parmi celles sélectionnés, qui sont liés à la formation et à l'intervenant
        intervenant_cours = cours.where(intervenant_id: intervenant.id, formation_id: formation.id).or(cours.where(intervenant_binome_id: intervenant.id, formation_id: formation.id))
        intervenant_vacations = intervenant.vacations.where(id: vacations.pluck(:id), formation_id: formation.id)
        intervenant_responsabilites = intervenant.responsabilites.where(id: responsabilites.pluck(:id), formation_id: formation.id)

        intervenant_cours.each do |c|
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

        intervenant_vacations.each do |vacation|
          if vacation.vacation_activite
            intitulé = vacation.vacation_activite.nom
            tarif = vacation.vacation_activite.vacation_activite_tarifs.find_by(statut: VacationActiviteTarif.statuts[vacation.intervenant.status])
            if tarif && tarif.forfait_hetd
              cumul_hetd += tarif.forfait_hetd
            end
          end

          cumul_vacations += vacation.montant || 0

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

        intervenant_responsabilites.each do |resp|
          montant_responsabilite = (resp.heures * Cour.Tarif).round(2)
          cumul_responsabilites += montant_responsabilite
          cumul_hetd += resp.heures

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

      end

      total = [
        "Total N°#{formation.eotp_nom}",nil,nil,nil,nil,nil,nil,nil,nil,nil,
        # Ss Hres CM
        cumul_cm,
        # SS HTD
        cumul_td,
        Cour.Tarif,
        # SSM TD
        cumul_tarif + cumul_vacations + cumul_responsabilites,
      ]

      sheet.row(index).replace total
      sheet.row(index).default_format = bold
      index += 2
    end

    # Todo: Mettre dans une variable la signature
    index += 5
    sheet.row(index).concat ["Fait à Paris le #{I18n.l(Date.today)}"]
    index += 5
    sheet.row(index).concat ['Barbara FITSCH-MOURAS']
    index += 1
    sheet.row(index).concat ['Responsable du service Formation et Développement']

    return book 
  end
end