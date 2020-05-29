# ENCODING: UTF-8

#app/controllers/api_controller.rb
module Api
    module V1
		class Api::V1::CoursController < ActionController::Base
			# Prevent CSRF attacks by raising an exception.
  			# For APIs, you may want to use :null_session instead.
 			protect_from_forgery with: :exception

		    skip_before_action :verify_authenticity_token

			def index
				# - Heure de début (sous forme de date)
				# - Heure de fin (sous forme de date)
				# - Durée (sous forme d'entier correspondant à des minutes)
				# - Salle (string)
				# - Matière (string)
				# - Promo (string)
				# - Nom de l'enseignant (string)
				# - Formation (string)

				cours = Cour.where(etat: Cour.etats.values_at(:planifié, :confirmé)).order(:debut)

				if params[:d]
					cours = cours.where("DATE(debut)=?", params[:d])
				else
					cours = cours.where("debut >= ?", Date.today)
				end

				render json: cours,
						methods:[:duree_json, :salle_json, :matiere_json, :formation_json, :intervenant_json],
						except:[:created_at, :updated_at, :id, :salle_id, :formation_id, :intervenant_id, :intervenant_binome_id, :etat, :duree, :ue, :nom]

				# 	d = DateTime.parse(params[:d] + 'T6:00:00')
				# 	f = DateTime.parse(params[:d] + 'T23:00:00')

				# 	render json: [{debut: d, fin: f, duree_json: 1020.0, salle_json: "!", 
				# 					matiere_json: "Appli en cours de maintenance",
				# 					intervenant_json: "Retrouvez le planning sur",
				# 					formation_json: "http://planning.iae-paris.com" }] 
			end	
							
		    def show
		    	cours = Cour.find(params[:id])
		    	render json: cours, methods:[:duree, :start_time_short_fr ,:nom_ou_ue, :formation_json, :photo_json, :salle_json], 
		    				except:[:created_at, :updated_at]
		    end

		end
	end
end