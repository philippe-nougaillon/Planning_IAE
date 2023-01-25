class AlertsController < ApplicationController
  before_action :set_alert, only: %i[ show edit update destroy ]
  before_action :is_user_authorized

  # GET /alerts or /alerts.json
  def index
    @alerts = Alert.all
    @alert = Alert.visibles.first

    @alerts = @alerts.reorder('alerts.'+ sort_column + ' ' + sort_direction)
  end

  # GET /alerts/1 or /alerts/1.json
  def show
  end

  # GET /alerts/new
  def new
    @alert = Alert.new

    @alert.debut = params[:debut] if params[:debut]
    @alert.fin = params[:fin] if params[:fin]
  end

  # GET /alerts/1/edit
  def edit
  end

  # POST /alerts or /alerts.json
  def create
    @alert = Alert.new(alert_params)

    respond_to do |format|
      if @alert.save
        format.html { redirect_to @alert, notice: "L'alerte a bien été créée." }
        format.json { render :show, status: :created, location: @alert }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /alerts/1 or /alerts/1.json
  def update
    respond_to do |format|
      if @alert.update(alert_params)
        format.html { redirect_to @alert, notice: "L'alerte a bien été modifiée." }
        format.json { render :show, status: :ok, location: @alert }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /alerts/1 or /alerts/1.json
  def destroy
    @alert.destroy
    respond_to do |format|
      format.html { redirect_to alerts_path, notice: "L'alerte a bien été supprimée." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_alert
      @alert = Alert.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def alert_params
      params.require(:alert).permit(:debut, :fin, :message, :etat)
    end

    def sort_column
      Alert.column_names.include?(params[:sort]) ? params[:sort] : 'updated_at'
    end
    
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
    end

    def is_user_authorized
      authorize Alert
    end
end
