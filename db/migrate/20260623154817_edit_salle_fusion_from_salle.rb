class EditSalleFusionFromSalle < ActiveRecord::Migration[7.2]
  def change
    # Ajoute les salles fusions correspondantes

    if salle = Salle.find_by(nom: "3.12")
      Salle.where(nom: ["3.1","3.2"]).update_all(salle_fusion_id: salle.id)
    end
    
    if salle = Salle.find_by(nom: "2.56")
      Salle.where(nom: ["2.5","2.6"]).update_all(salle_fusion_id: salle.id)
    end
  end
end
