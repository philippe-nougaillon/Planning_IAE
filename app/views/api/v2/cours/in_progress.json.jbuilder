json.array!(@cours.includes(:intervenant, :formation, :salle)) do |cour|
    json.extract! cour, :id, 
                        :etat,
                        :formation_id,
                        :debut_fin_json_v2, 
                        :formation_json_v2,
                        :formation_color_json_v2, 
                        :matiere_json, 
                        :intervenant_json, 
                        :salle_json_v2, 
                        :progress_bar_pct2
end
