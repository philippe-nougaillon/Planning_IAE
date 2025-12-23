class CoursEtatsServicesToXls < ApplicationService
  require 'spreadsheet'
  attr_reader :cours

  def initialize(cours, intervenants, start_date, end_date, is_cours_showed, is_vacations_showed, is_responsabilites_showed)
    @cours = cours
    @intervenants = intervenants
    @start_date = start_date
    @end_date = end_date
    @is_cours_showed = is_cours_showed
    @is_vacations_showed = is_vacations_showed
    @is_responsabilites_showed = is_responsabilites_showed
  end

  def call
    Spreadsheet.client_encoding = 'UTF-8'

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Etats de services'
    bold = Spreadsheet::Format.new :weight => :bold, :size => 10

    sheet.row(0).concat ['Type','Intervenant','Date','Heure','Formation','Code','Intitulé','Etat','Commentaires',
      'Durée','HSS?','E-learning?','Binôme','CM/TD?', 'Taux_TD','HETD','Montant','Cumul_hetd','Dépassement']

    sheet.row(0).default_format = bold

    index = 1
    total_hetd = 0

    @intervenants.each do | intervenant |

      # Passe au suivant si intervenant est 'A CONFIRMER'
      next if intervenant.id == 445

      nbr_heures_statutaire = intervenant.nbr_heures_statutaire || 0

      cumul_hetd = 0.00

      if @is_cours_showed
        cours_ids = @cours.where(intervenant: intervenant).order(:debut).pluck(:id)
        cours_ids << @cours.where(intervenant_binome: intervenant).pluck(:id)
        cours_ids = cours_ids.flatten

        cours_ids.each do |id|
          c = Cour.find(id)

          if c.imputable?
            cumul_hetd += c.HETD
            montant_service = c.montant_service.round(2)
          end

          formation = Formation.find(c.formation_id)

          fields_to_export = [
            'C',
            intervenant.nom_prenom,
            I18n.l(c.debut.to_date),
            c.debut.strftime("%k:%M"), 
            formation.abrg, 
            formation.code_analytique_avec_indice(c.debut), 
            c.nom_ou_ue,
            c.etat,
            c.commentaires,
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
      end

      if @is_vacations_showed
        @vacations = intervenant.vacations.where("date BETWEEN ? AND ?", @start_date, @end_date)

        @vacations.each do |vacation|
          if vacation.vacation_activite
            intitulé = vacation.vacation_activite.nom
            tarif = vacation.vacation_activite.vacation_activite_tarifs.find_by(statut: VacationActiviteTarif.statuts[vacation.intervenant.status])
            if tarif && tarif.forfait_hetd
              cumul_hetd += tarif.forfait_hetd
            end
          end

          formation = Formation.find(vacation.formation_id)
          
          fields_to_export = [
            'V',
            intervenant.nom_prenom,
            I18n.l(vacation.date.to_date),
            nil,
            formation.nom,
            formation.code_analytique_avec_indice(vacation.date),
            intitulé || vacation.titre,
            nil, nil, 
            vacation.qte,
            nil, nil, nil, 
            'TD', 1,
            vacation.forfaithtd,
            vacation.montant,
            cumul_hetd,
            ((nbr_heures_statutaire > 0) && (cumul_hetd >= nbr_heures_statutaire) ? cumul_hetd - nbr_heures_statutaire : nil)
          ]
          sheet.row(index).replace fields_to_export
          index += 1
        end
      end

      if @is_responsabilites_showed
        @responsabilites = intervenant.responsabilites.where("debut BETWEEN ? AND ?", @start_date, @end_date)

        @responsabilites.each do |resp|
          montant_responsabilite = (resp.heures * Cour.Tarif).round(2)
          cumul_hetd += resp.heures
          formation = Formation.find(resp.formation_id)

          fields_to_export = [
            'R',
            intervenant.nom_prenom,
            I18n.l(resp.debut),
            nil,
            formation.nom,
            formation.code_analytique_avec_indice(resp.debut),
            resp.titre,
            nil,
            nil, 
            resp.heures, 
            nil, nil, nil,
            'TD', 1, nil,
            montant_responsabilite,
            cumul_hetd,
            ((nbr_heures_statutaire > 0) && (cumul_hetd >= nbr_heures_statutaire) ? cumul_hetd - nbr_heures_statutaire : nil)
          ]
          sheet.row(index).replace fields_to_export
          index += 1
        end
      end

      return book 
    end
  end
end