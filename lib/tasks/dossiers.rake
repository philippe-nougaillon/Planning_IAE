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

end