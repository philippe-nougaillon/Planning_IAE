class SujetsController < ApplicationController
  before_action :set_sujet, only: %i[ show edit update destroy deposer deposer_done ]
  before_action :is_user_authorized
  skip_before_action :authenticate_user!, only: %i[ show deposer deposer_done]

  # GET /sujets or /sujets.json
  def index
    @sujets = Sujet.ordered

    if params[:nom].present?
      # @sujets = @sujets.joins(:cours).where()
    end

    if params[:workflow_state].present?
      @sujets = @sujets.where("workflow_state = ?", params[:workflow_state].to_s.downcase)
    end

    @sujets = @sujets.paginate(page: params[:page], per_page: 20)
  end

  # GET /sujets/1 or /sujets/1.json
  def show
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
    @sujet.valider_sujet(current_user.id)

    redirect_to @sujet, notice: "Sujet validé avec succès."
  end

  def relancer
    @sujet.relancer_sujet(current_user.id)

    redirect_to @sujet, notice: "Sujet relancé avec succès."
  end

  def rejeter
    @sujet.rejeter_sujet(current_user.id)
    
    redirect_to @sujet, notice: "Sujet rejeté avec succès. L'intervenant vient d'être informé."
  end

  def archiver
    @sujet.archiver_sujet(current_user.id)
    redirect_to @sujet, notice: 'Sujet archivé, le sujet a été supprimé'
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
      ['cours.debut', 'intervenants.nom','sujets.workflow_state', 'sujets.created_at', 'sujets.updated_at']
    end

    def sort_column
      sortable_columns.include?(params[:column_sujet]) ? params[:column_sujet] : "nom"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction_sujet]) ? params[:direction_sujet] : "asc"
    end

    def is_user_authorized
      authorize @sujet ? @sujet : Sujet
    end
end
