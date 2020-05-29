class MutateFormationNomTauxTd < ActiveRecord::Migration[5.2]
  def change
    Formation.where(Taux_TD: 1).update(nomTauxTD: 'TD')
    Formation.where(Taux_TD: 1.5).update(nomTauxTD: 'CM')
    Formation.where(Taux_TD: 3).update(nomTauxTD: '3xTD')
  end
end
