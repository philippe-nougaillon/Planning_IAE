class ChangeDefaultValueToIntervenantDoublonField < ActiveRecord::Migration[6.1]
  def change
    change_column :intervenants, :doublon, :boolean, default: false
    
    Intervenant.where(doublon: nil).update_all(doublon: false)
  end
end
