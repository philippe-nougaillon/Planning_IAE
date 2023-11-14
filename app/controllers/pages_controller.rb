class PagesController < ApplicationController
  before_action :is_user_authorized

  def mentions_légales
  end

  def mes_sessions
    @cours = Etudiant
            .where("LOWER(etudiants.email) = ?", current_user.email.downcase)
            .first
            .formation
            .cours
            .where("DATE(debut) = ?", Date.today)
            .order(:debut)
  end

  def signature
    @cour = Cour.find(params[:cour_id])
  end

  private
    def is_user_authorized
      authorize :pages
    end
end
