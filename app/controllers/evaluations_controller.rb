class EvaluationsController < ApplicationController
  before_action :set_evaluation, only: %i[ show edit update destroy ]
  before_action :is_user_authorized

  # GET /evaluations or /evaluations.json
  def index
    case current_user.role when "administrateur"
      @evaluations = Evaluation.all

      if params[:search].present?
        @evaluations = @evaluations.where("matière LIKE :search OR examen LIKE :search", {search: "%#{params[:search]}%".downcase})
      end
      if params[:formation_id].present?
        @evaluations = @evaluations.joins(etudiant: :formation).where(formations: { id: params[:formation_id] })
      end
    when 'étudiant'
      etudiant = Etudiant.find_by("LOWER(etudiants.email) = ?", current_user.email.downcase)
      @evaluations = etudiant.evaluations
    end

    if params[:du].present?
      @evaluations = @evaluations.where("matière LIKE :search OR examen LIKE :search", {search: "%#{params[:search]}%".downcase})
    end
  end

  # GET /evaluations/1 or /evaluations/1.json
  def show
  end

  # GET /evaluations/new
  def new
    @evaluation = Evaluation.new
    @etudiants = Etudiant.all.order(:nom, :prénom)
  end

  # GET /evaluations/1/edit
  def edit
    @etudiants = Etudiant.all.order(:nom, :prénom)
  end

  # POST /evaluations or /evaluations.json
  def create
    @evaluation = Evaluation.new(evaluation_params)

    respond_to do |format|
      if @evaluation.save
        format.html { redirect_to evaluations_url, notice: "Evaluation créée avec succès." }
        format.json { render :show, status: :created, location: @evaluation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @evaluation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /evaluations/1 or /evaluations/1.json
  def update
    respond_to do |format|
      if @evaluation.update(evaluation_params)
        format.html { redirect_to evaluations_url, notice: "Evaluation modifiée avec succès." }
        format.json { render :show, status: :ok, location: @evaluation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @evaluation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /evaluations/1 or /evaluations/1.json
  def destroy
    @evaluation.destroy!

    respond_to do |format|
      format.html { redirect_to evaluations_url, notice: "Evaluation supprimée avec succès." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_evaluation
      @evaluation = Evaluation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def evaluation_params
      params.require(:evaluation).permit(:etudiant_id, :note, :date, :examen, :matière)
    end

    def is_user_authorized
      authorize Evaluation
    end
end
