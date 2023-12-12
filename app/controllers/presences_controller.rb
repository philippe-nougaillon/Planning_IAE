class PresencesController < ApplicationController
  before_action :set_presence, only: %i[ show edit update destroy valider rejeter]
  before_action :is_user_authorized, except: %i[show valider rejeter]

  # GET /presences or /presences.json
  def index
    @presences = Presence.ordered

    if params[:search].present?
      @presences = @presences.joins(:etudiant).where("etudiants.nom ILIKE :search OR etudiants.prénom ILIKE :search", { search: "%#{params[:search]}%" })
    end

    if params[:formation_id].present?
      @presences = @presences.joins(:cour).where('cour.formation_id': params[:formation_id])
    end

    if params[:ue].present?
      @presences = @presences.where(code_ue: params[:ue])
    end

    if params[:intervenant].present?
      intervenant = params[:intervenant].strip
      intervenant_id = Intervenant.find_by(nom: intervenant.split(' ').first, prenom: intervenant.split(' ').last.rstrip)
      @presences = @presences.joins(:cour).where('cour.intervenant_id': intervenant_id)
    end

    if params[:cours_id].present?
      @presences = @presences.where(cour_id: params[:cours_id])
    end

    if params[:workflow_state].present?
      @presences = @presences.where(workflow_state: params[:workflow_state])
    end

    @presences = @presences.paginate(page: params[:page], per_page: 20)
  end

  # GET /presences/1 or /presences/1.json
  def show
    authorize @presence
  end

  # GET /presences/new
  def new
    @presence = Presence.new
  end

  # GET /presences/1/edit
  def edit
  end

  # POST /presences or /presences.json
  def create
    @presence = Presence.new(presence_params)

    respond_to do |format|
      if @presence.save
        format.html { redirect_to @presence, notice: "Presence was successfully created." }
        format.json { render :show, status: :created, location: @presence }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @presence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /presences/1 or /presences/1.json
  def update
    respond_to do |format|
      if @presence.update(presence_params)
        format.html { redirect_to @presence, notice: "Presence was successfully updated." }
        format.json { render :show, status: :ok, location: @presence }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @presence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /presences/1 or /presences/1.json
  def destroy
    @presence.destroy
    respond_to do |format|
      format.html { redirect_to presences_url, notice: "Presence was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def valider
    authorize @presence
    @presence.valider!
    redirect_to request.referrer, notice: 'Présence validée'
  end

  def rejeter
    authorize @presence 
    @presence.rejeter!
    redirect_to request.referrer, notice: 'Présence rejetée'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_presence
      @presence = Presence.find_by(slug: params[:id])
    end

    # Only allow a list of trusted parameters through.
    def presence_params
      params.require(:presence).permit(:cour_id, :user_id, :signature)
    end

    def is_user_authorized
      authorize Presence
    end
end
