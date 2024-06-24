class VacationActivitesController < ApplicationController
  before_action :set_vacation_activite, only: %i[ show edit update destroy ]
  before_action :is_user_authorized

  # GET /vacation_activites or /vacation_activites.json
  def index
    @vacation_activites = VacationActivite.ordered
    # @vacation_activites = @vacation_activites.reorder("#{sort_column} #{sort_direction}")  
  end

  # GET /vacation_activites/1 or /vacation_activites/1.json
  def show
  end

  # GET /vacation_activites/new
  def new
    @vacation_activite = VacationActivite.new
  end

  # GET /vacation_activites/1/edit
  def edit
  end

  # POST /vacation_activites or /vacation_activites.json
  def create
    @vacation_activite = VacationActivite.new(vacation_activite_params)

    respond_to do |format|
      if @vacation_activite.save
        format.html { redirect_to vacation_activite_url(@vacation_activite), notice: "Vacation activite was successfully created." }
        format.json { render :show, status: :created, location: @vacation_activite }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vacation_activite.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vacation_activites/1 or /vacation_activites/1.json
  def update
    respond_to do |format|
      if @vacation_activite.update(vacation_activite_params)
        format.html { redirect_to vacation_activite_url(@vacation_activite), notice: "Vacation activite was successfully updated." }
        format.json { render :show, status: :ok, location: @vacation_activite }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @vacation_activite.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vacation_activites/1 or /vacation_activites/1.json
  def destroy
    @vacation_activite.destroy!

    respond_to do |format|
      format.html { redirect_to vacation_activites_url, notice: "Vacation activite was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vacation_activite
      @vacation_activite = VacationActivite.find(params[:id])
    end

    # def sortable_columns
    #   ['vacation_activites.nature','vacation_activites.nom','vacation_activite_tarif.statut']
    # end

    # def sort_column
    #   sortable_columns.include?(params[:column]) ? params[:column] : "nature"
    # end

    # def sort_direction
    #   %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    # end

    # Only allow a list of trusted parameters through.
    def vacation_activite_params
      params.require(:vacation_activite).permit(:nature, :nom, vacation_activite_tarifs_attributes: [:id, :_destroy, :statut, :prix, :forfait_hetd, :max])
    end

    def is_user_authorized
      authorize VacationActivite
    end
end
