class SujetsController < ApplicationController
  before_action :set_sujet, only: %i[ show edit update destroy deposer deposer_done valider rejeter relancer archiver ]
  before_action :is_user_authorized
  skip_before_action :authenticate_user!, only: %i[ show deposer deposer_done]

  # GET /sujets or /sujets.json
  def index
    if params[:archive].blank?
      @sujets = Sujet.where.not(workflow_state: "archivé").joins(:cour)
    else
      @sujets = Sujet.all.joins(:cour)
    end

    if params[:gestionnaire].present?
      formations = Formation.where(user_id: current_user.id)
      sujet_ids = []
      @sujets.each do |sujet|
        if formations.include?(sujet.formation)
          sujet_ids << sujet.id
        end
      end

      @sujets = @sujets.where(id: sujet_ids)
    end

    if params[:formation].present?
      formation_id = Formation.find_by(nom: params[:formation]).id
      examens_from_formation = Cour.where(formation_id: formation_id).select{|cour| cour.examen?}
      @sujets = @sujets.where(cour_id: examens_from_formation)
    end

    if params[:intervenant].present?
      nom_prenom_intervenant = params[:intervenant].split(' ', 2)
      intervenant_id = Intervenant.find_by(nom: nom_prenom_intervenant.first, prenom: nom_prenom_intervenant.last.rstrip).id
      examens_from_intervenant = Cour.where(intervenant_binome_id: intervenant_id).select{|cour| cour.examen?}
      @sujets = @sujets.where(cour_id: examens_from_intervenant)
    end

    if params[:workflow_state].present?
      @sujets = @sujets.where("workflow_state = ?", params[:workflow_state].to_s.downcase)
    end

    @sujets = @sujets.reorder(Arel.sql("#{sort_column} #{sort_direction}"))
    @sujets = @sujets.paginate(page: params[:page], per_page: 20)
  end

  # GET /sujets/1 or /sujets/1.json
  def show
    @audits = @sujet.audits.reorder(id: :desc).paginate(page:params[:page], per_page: 10)
  end

  # GET /sujets/new
  def new
    @sujet = Sujet.new
  end

  # GET /sujets/1/edit
  def edit
  end

  # POST /sujets or /sujets.json
  def create
    @sujet = Sujet.new(sujet_params)

    respond_to do |format|
      if @sujet.save
        format.html { redirect_to @sujet, notice: "Sujet créé avec succès." }
        format.json { render :show, status: :created, location: @sujet }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sujet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sujets/1 or /sujets/1.json
  def update
    respond_to do |format|
      if @sujet.update(sujet_params)
        format.html { redirect_to @sujet, notice: "Sujet modifié avec succès.", status: :see_other }
        format.json { render :show, status: :ok, location: @sujet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sujet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sujets/1 or /sujets/1.json
  def destroy
    @sujet.destroy!

    respond_to do |format|
      format.html { redirect_to sujets_path, notice: "Sujet supprimé avec succès.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def deposer
    if params[:sujet]
      @sujet.update(sujet_params)
      @sujet.déposer!
      redirect_to deposer_done_sujet_path(@sujet)
    else 
      redirect_to request.referrer, alert: "Il faut ajouter le sujet"
    end
  end

  def deposer_done
  end

  def valider
    @sujet.valider!

    examen = @sujet.cour
    nombre_jours = examen.days_between_today_and_debut
    ValidationSujetJob.perform_later(examen, nombre_jours)

    redirect_to @sujet, notice: "Sujet validé avec succès."
  end

  def relancer
    @sujet.relancer!

    RelancerSujetJob.perform_later(@sujet)

    redirect_to @sujet, notice: "Sujet relancé avec succès."
  end

  def rejeter
    @sujet.rejeter!

    RejeterSujetJob.perform_later(@sujet)
    
    redirect_to @sujet, notice: "Sujet rejeté avec succès."
  end

  def archiver
    @sujet.archiver!

    @sujet.sujet.purge

    redirect_to @sujet, notice: 'Sujet archivé avec succès.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sujet
      @sujet = Sujet.find_by(slug: params[:id])
      if @sujet.nil?
        redirect_to root_path, alert: "Élément introuvable"
      end
    end

    # Only allow a list of trusted parameters through.
    def sujet_params
      params.require(:sujet).permit(:sujet)
    end

    def sortable_columns
      ['cours.debut','sujets.workflow_state', 'sujets.created_at', 'sujets.updated_at']
    end

    def sort_column
      sortable_columns.include?(params[:column_sujet]) ? params[:column_sujet] : "debut"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction_sujet]) ? params[:direction_sujet] : "asc"
    end

    def is_user_authorized
      authorize @sujet ? @sujet : Sujet
    end
end
