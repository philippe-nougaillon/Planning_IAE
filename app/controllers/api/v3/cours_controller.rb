module Api
  	module V3
		class Api::V3::CoursController < ActionController::Base

			# Prevent CSRF attacks by raising an exception.
			# For APIs, you may want to use :null_session instead.
			protect_from_forgery with: :exception

			skip_before_action :verify_authenticity_token
			
			def index
				@cours = Cour
							.where("DATE(debut) >= ?", params[:d])
							.order(:debut, :fin)
							.paginate(page: params[:page], per_page: 25)
			end
			
		end
	end
end