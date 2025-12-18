namespace :dossiers do
  desc "Relance automatique des dossiers qui sont en attente"
  task relance_dossiers: :environment do

    # Dossiers à relancer dans la période actuelle
    dossiers = Dossier.where(période: AppConstants::PÉRIODE)
                      .where.not(workflow_state: ["nouveau", "déposé", "validé", "archivé"])

    dossiers_à_relancer = dossiers.where("DATE(updated_at) < ?", Date.today - 30.days)

    # Pour chaque dossier à relancer, on passe à l'état suivant et on envoie le mail
    dossiers_à_relancer.each do |dossier|
      dossier.relancer_dossier(0)
    end
  end

  desc "Liste les Intervenants CEV qui donneront un cours le mois suivant et qui n'ont pas de dossier RH"
  task notif_dossiers_rh_manquants: :environment do
    if Date.today.day == Date.today.end_of_month
      début = (Date.today + 2.months).beginning_of_month
      fin = (Date.today + 2.months).end_of_month
      année = (début.month >= 9) ? début.year : début.year - 1
      période = "#{année}/#{année + 1}"
      intervenants_sans_dossier = Intervenant.sans_dossier(période, début, fin)
      if intervenants_sans_dossier.present?
        NotifDossiersRhManquantsJob.perform_later(intervenants_sans_dossier)
      end
    end
  end

  desc "Relance automatique des dossiers qui sont ne sont pas validés, lorsque l'intervenant a bientôt un cours"
  task relance_dossiers_urgents: :environment do
    date_debut_p, date_fin_p = Dossier.dates_début_fin_année_scolaire(AppConstants::PÉRIODE)
    cible = Date.today + 15.days

    dossiers_à_relancer = Dossier.joins(intervenant: :cours)
      .where(période: AppConstants::PÉRIODE)
      .where.not(workflow_state: ["nouveau", "déposé", "validé", "archivé"])
      .where(cours: { debut: date_debut_p..date_fin_p }) # Uniquement les cours de la période
      .group("dossiers.id")
      .having("DATE(MIN(cours.debut)) = ?", cible)

    # Pour chaque dossier à relancer, on passe à l'état suivant et on envoie le mail
    dossiers_à_relancer.each do |dossier|
      dossier.relancer_dossier_urgent(0)
    end
  end
end