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
    @presence = Presence.new(cour_id: params[:cour_id], user_id: current_user.id, code_ue: @cour.code_ue)
  end

  def signature_do
    @presence = Presence.new(params.require(:presence).permit(:cour_id, :user_id, :signature, :code_ue))
    if @presence.save
      @presence.update!(ip: @presence.audits.first.remote_address)
      redirect_to mes_sessions_path, notice: "Signé"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def is_user_authorized
      authorize :pages
    end
end
