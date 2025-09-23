class SujetsController < ApplicationController
  before_action :set_sujet, only: %i[ show edit update destroy ]
  before_action :is_user_authorized

  # GET /sujets or /sujets.json
  def index
    @sujets = Sujet.ordered

    if params[:archive].blank?
      @sujets = @sujets.not_archived
    end
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
      params.require(:sujet).permit(:cour_id, :mail_log_id, :workflow_state, :slug)
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
