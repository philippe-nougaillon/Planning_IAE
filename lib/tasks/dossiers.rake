namespace :dossiers do
  desc "Relance automatique des dossiers qui sont en attente"
  task relance_dossiers: :environment do

    # Dossiers à relancer dans la période actuelle
    dossiers = Dossier.where(période: AppConstants::PÉRIODE)
                      .where.not(workflow_state: ["nouveau", "déposé", "validé", "non_conforme", "archivé"])

    relances = dossiers.where(workflow_state: "envoyé").where("DATE(updated_at) between ? AND ?", Date.today - 60.days, Date.today)
    relances += dossiers.where(workflow_state: "relancé 1 fois").where("DATE(updated_at) between ? AND ?", Date.today - 15.days, Date.today)
    relances += dossiers.where(workflow_state: "relancé 2 fois").where("DATE(updated_at) between ? AND ?", Date.today - 7.days, Date.today)
    relances += dossiers.where(workflow_state: "relancé 3 fois").where("DATE(updated_at) between ? AND ?", Date.today - 3.days, Date.today)
    relances += dossiers.where(workflow_state: ["relancé 4 fois", "relancé 5 fois", "relancé 6 fois", "relancé 7 fois", "relancé 8 fois", "relancé 9 fois", "relancé 10 fois"]).where("DATE(updated_at) between ? AND ?", Date.today - 10.days, Date.today)

    # Pour chaque dossier à relancer, on passe à l'état suivant et on envoie le mail
    relances.each do |dossier|
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
end