# ENCODING: UTF-8

#app/controllers/api_controller.rb
module Api
  module V2
		class Api::V2::CoursController < ActionController::Base

			# Prevent CSRF attacks by raising an exception.
			# For APIs, you may want to use :null_session instead.
			protect_from_forgery with: :exception

			skip_before_action :verify_authenticity_token
			
			respond_to :json

			def index
				#@cours = Cour.where(etat: Cour.etats.values_at(:planifié, :confirmé))
				@cours = Cour
									.where("DATE(debut) = ?", params[:d])
							 		.order(:debut, :fin)
			end
			
			def in_progress
				@cours = Cour
									.where(etat: Cour.etats.values_at(:planifié, :confirmé))
									.where("DATE(debut) = ?", Date.today)
									.where("intervenant_id = ? OR intervenant_binome_id = ?", params[:intervenant_id], params[:intervenant_id])
									.order(:debut, :fin)
			end	

		end
	end
end