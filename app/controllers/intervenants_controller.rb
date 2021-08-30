# ENCODING: UTF-8

class IntervenantsController < ApplicationController
  before_action :set_intervenant, only: [:show, :edit, :update, :destroy]

  # check if logged and admin  
  # before_filter do 
  #   redirect_to new_user_session_path unless current_user && current_user.admin?
  # end

  # GET /intervenants
  # GET /intervenants.json
  def index
    authorize Intervenant
    
    params[:column] ||= session[:column]
    params[:direction] ||= session[:direction]

    @intervenants = Intervenant.all

    unless params[:nom].blank?
      s = "%#{params[:nom]}%".downcase
      @intervenants = @intervenants.where("LOWER(nom) like ? or LOWER(prenom) like ?", s, s)
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
                      .reorder("#{sort_column} #{sort_direction}")  
                      .paginate(page: params[:page], per_page: 10)
  end

  # GET /intervenants/1
  # GET /intervenants/1.json
  def show
    @formations = @intervenant.formations.uniq
    @salles_habituelles = @intervenant.cours
                                      .select('cours.id')
                                      .group(:salle_id)
                                      .count(:id)
                                      .sort_by{|k, v| v}
                                      .reverse
                                      .collect{ |x| x.first ? "#{Salle.find(x.first).try(:nom)} (#{ x.last })" : nil }
                                      .select{ |x| !x.nil? }
                                      .join(', ')
  end

  # GET /intervenants/new
  def new
    @intervenant = Intervenant.new
    @intervenant.notifier = true
    10.times { @intervenant.responsabilites.build }
  end

  # GET /intervenants/1/edit
  def edit
    3.times { @intervenant.responsabilites.build }
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
        format.html { render :new }
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
      format.html { redirect_to intervenants_url, notice: 'Intervenant supprimé.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_intervenant
      @intervenant = Intervenant.find(params[:id])
    end

    def sortable_columns
      ['intervenants.nom','intervenants.created_at','intervenants.status','intervenants.nbr_heures_statutaire','intervenants.remise_dossier_srh']
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
       :nbr_heures_statutaire, :date_naissance, :memo, :notifier,
       responsabilites_attributes: [:id, :debut, :fin, :titre, :formation_id, :heures, :commentaires, :_destroy])
    end

end
