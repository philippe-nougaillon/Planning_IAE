module Api
  	module V3
		class Api::V3::CoursController < ActionController::Base

			# Prevent CSRF attacks by raising an exception.
			# For APIs, you may want to use :null_session instead.
			protect_from_forgery with: :exception

			skip_before_action :verify_authenticity_token
			
			def index
				@cours = Cour.where("DATE(debut) >= ?", params[:d])
				unless params[:search].blank?
					s = params[:search].upcase
					@cours = @cours.joins(:formation, :intervenant).where("formations.nom LIKE ? OR intervenants.nom LIKE ?", "%#{ s }%", "%#{ s }%")					
				end
				@cours = @cours.order(:debut, :fin)
				@cours = @cours.paginate(page: params[:page], per_page: 25)
			end
			
		end
	end
end