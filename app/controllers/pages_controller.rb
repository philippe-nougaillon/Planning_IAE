class PagesController < ApplicationController
  before_action :is_user_authorized

  def mentions_légales
  end

  def mes_sessions
    @etudiant = Etudiant.find_by("LOWER(etudiants.email) = ?", current_user.email.downcase)
    @cours = @etudiant
            .formation
            .cours
            .where("DATE(debut) = ?", Date.today)
            .order(:debut)
  end

  def signature
    @cour = Cour.find(params[:cour_id])
    now = ApplicationController.helpers.time_in_paris_selon_la_saison
    if current_user.étudiant?
      @etudiant = @cour.etudiants.find_by("LOWER(etudiants.email) = ?", current_user.email.downcase)
      @presence = Presence.create(cour_id: @cour.id, etudiant_id: @etudiant.id, code_ue: @cour.code_ue, signée_le: now)
    elsif current_user.intervenant?
      @intervenant = @cour.intervenant
      @presence = Presence.create(cour_id: @cour.id, intervenant_id: @intervenant.id, code_ue: @cour.code_ue, signée_le: now)
    end
  end

  def signature_do
    @presence = Presence.find(params[:presence][:id])
    @presence.workflow_state = 'signée'
    @presence.ip = request.remote_ip
    @presence.signature = params[:presence][:signature]
    if @presence.save
      if current_user.intervenant? || current_user.enseignant? 
        @presence.cour.presences.where(workflow_state: 'signée').update_all(workflow_state: 'validée')

        absents = @presence.cour.etudiants.where.not(id: @presence.cour.presences.pluck(:etudiant_id))

        absents.each do |absent|
          @presence.cour.presences.create(etudiant_id: absent.id, workflow_state: 'manquante')
        end
        flash[:notice] = 'Toutes les signatures de présences ont été validées. Les étudiants qui n\'ont pas signé sont notés absent'
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
