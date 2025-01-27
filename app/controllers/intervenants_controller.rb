# ENCODING: UTF-8

class IntervenantsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ invitations calendrier ]
  before_action :set_intervenant, only: [:show, :invitations, :edit, :update, :destroy, :calendrier]
  before_action :is_user_authorized

  # check if logged and admin  
  # before_filter do 
  #   redirect_to new_user_session_path unless current_user && current_user.admin?
  # end

  # GET /intervenants
  # GET /intervenants.json
  def index
    
    params[:column] ||= session[:column]
    params[:direction] ||= session[:direction]

    @intervenants = Intervenant.all

    unless params[:nom].blank?
      @intervenants = @intervenants.where("LOWER(nom) like :search or LOWER(prenom) like :search", {search: "%#{params[:nom]}%".downcase})
    end

    unless params[:doublon].blank?
      @intervenants = @intervenants.where(doublon:true)
    end

    unless params[:status].blank?
      @intervenants = @intervenants.where("status = ?", params[:status])
    end

    session[:column] = params[:column]
    session[:direction] = params[:direction]

    @intervenants = @intervenants
                      .reorder(Arel.sql("#{sort_column} #{sort_direction}"))  
                      .paginate(page: params[:page], per_page: 10)
  end

  def invitations
    @invits = @intervenant.invits.where.not(workflow_state: 'non_retenue')

    unless params[:formation].blank?
      @invits = @invits.joins(:formation).where("formations.id = ?", params[:formation])
    end

    unless params[:workflow_state].blank?
      @invits = @invits.where("invits.workflow_state = ?", params[:workflow_state].to_s.downcase)
    end

    @formations = Formation.where(id: @invits.joins(:formation).pluck("formations.id").uniq)
    @invits = @invits.joins(:cour).reorder('cours.debut').paginate(page: params[:page], per_page: 20)
  end

  # GET /intervenants/1
  # GET /intervenants/1.json
  def show
    @user = @intervenant.linked_user
    @formations = @intervenant.formations.uniq
    @salles_habituelles = @intervenant.cours
                                      .joins(:salle)
                                      .where("salles.bloc != 'Z'")
                                      .select('cours.id')
                                      .group(:salle_id)
                                      .count(:id)
                                      .sort_by{|k, v| v}
                                      .reverse
                                      .first(5)

    @average_count = 0
    @salles_habituelles.map{|x| @average_count += x.last.to_i / 5}
  end

  # GET /intervenants/new
  def new
    @intervenant = Intervenant.new
    @intervenant.notifier = true
    @intervenant.année_entrée = Date.today.year
  end

  # GET /intervenants/1/edit
  def edit
  end

  # POST /intervenants
  # POST /intervenants.json
  def create
    @intervenant = Intervenant.new(intervenant_params)

    respond_to do |format|
      if @intervenant.save
        format.html { redirect_to @intervenant, notice: 'Intervenant ajouté.' }
        format.json { render :show, status: :created, location: @intervenant }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @intervenant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /intervenants/1
  # PATCH/PUT /intervenants/1.json
  def update
    respond_to do |format|
      if @intervenant.update(intervenant_params)
        format.html { redirect_to @intervenant, notice: 'Intervenant modifié.' }
        format.json { render :show, status: :ok, location: @intervenant }
      else
        format.html { render :edit }
        format.json { render json: @intervenant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /intervenants/1
  # DELETE /intervenants/1.json
  def destroy
    @intervenant.destroy
    respond_to do |format|
      format.html { redirect_to intervenants_path, notice: 'Intervenant supprimé.' }
      format.json { head :no_content }
    end
  end

  def calendrier
    respond_to do |format|
      format.ics do
        @calendar = Cour.generate_ical(@intervenant.cours)
        filename = "Calendrier_#{@intervenant.nom}"
        response.headers['Content-Disposition'] = 'attachment; filename="' + filename + '.ics"'
        headers['Content-Type'] = "text/calendar; charset=UTF-8"
        render plain: @calendar.to_ical
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_intervenant
      @intervenant = Intervenant.friendly.find(params[:id])
    end

    def sortable_columns
      ['intervenants.nom','intervenants.created_at','intervenants.status','intervenants.nbr_heures_statutaire','intervenants.remise_dossier_srh', 'intervenants.doublon']
    end

    def sort_column
        sortable_columns.include?(params[:column]) ? params[:column] : "nom"
    end

    def sort_direction
        %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def intervenant_params
      params.require(:intervenant).permit(:nom, :prenom, :email, :linkedin_url, :titre1, :titre2, :spécialité,
       :téléphone_fixe, :téléphone_mobile, :bureau, :photo, :status, :remise_dossier_srh, :adresse, :cp, :ville, :doublon,
       :nbr_heures_statutaire, :date_naissance, :memo, :notifier, :année_entrée, :email2,
       responsabilites_attributes: [:id, :debut, :fin, :titre, :formation_id, :heures, :commentaires, :_destroy])
    end

    def is_user_authorized
      authorize Intervenant
    end

end
