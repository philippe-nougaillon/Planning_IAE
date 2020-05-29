# ENCODING: UTF-8

#app/controllers/api_controller.rb
module Api
    module V2
        class Api::V2::EtudiantsController < ActionController::Base
  
            # Prevent CSRF attacks by raising an exception.
            # For APIs, you may want to use :null_session instead.
            protect_from_forgery with: :exception
            skip_before_action :verify_authenticity_token

            respond_to :json
  
            def index
                @etudiants = Etudiant.where(formation_id: params[:formation_id])
            end
        end
    end
end