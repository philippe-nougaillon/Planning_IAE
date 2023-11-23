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
    @presence = Presence.new(cour_id: params[:cour_id], user_id: current_user.id, code_ue: @cour.code_ue, role: current_user.role)
  end

  def signature_do
    @presence = Presence.new(params.require(:presence).permit(:cour_id, :user_id, :signature, :code_ue, :role))
    if @presence.save
      @presence.update!(ip: @presence.audits.first.remote_address)

      if current_user.intervenant? || current_user.enseignant? 
        @presence.cour.presences.where(workflow_state: 'nouvelle').update_all(workflow_state: 'validée')
        flash[:notice] = 'Toutes les signatures de présences ont été validées'
      else
        flash[:notice] = 'Signé'
      end
      redirect_to current_user.étudiant? ? mes_sessions_path : mes_sessions_intervenant_path(Intervenant.where("LOWER(intervenants.email) = ?", current_user.email.downcase).first.id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def is_user_authorized
      authorize :pages
    end
end
