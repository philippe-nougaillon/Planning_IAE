module Api
    module V4
        class Api::V4::CoursController < ActionController::Base
            # Prevent CSRF attacks by raising an exception.
            # For APIs, you may want to use :null_session instead.
            protect_from_forgery with: :exception

            skip_before_action :verify_authenticity_token
            
            respond_to :json

            def index
                now = ApplicationController.helpers.time_in_paris_selon_la_saison
                
                @cours = Cour.where(etat: Cour.etats.values_at(:planifié, :confirmé))
                             .where("DATE(fin) = ? AND fin > ?", now.to_date, now.to_s(:db))
                             .includes(:formation, :intervenant, :salle) 
                             .order(:debut)
            end
      end
  end
end