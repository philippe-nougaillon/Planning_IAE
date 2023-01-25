class OuverturesController < ApplicationController
  before_action :set_ouverture, only: %i[ show edit update destroy ]
  before_action :is_user_authorized

  # GET /ouvertures or /ouvertures.json
  def index
    @ouvertures = Ouverture.all
  end

  # GET /ouvertures/1 or /ouvertures/1.json
  def show
  end

  # GET /ouvertures/new
  def new
    @ouverture = Ouverture.new
  end

  # GET /ouvertures/1/edit
  def edit
  end

  # POST /ouvertures or /ouvertures.json
  def create
    @ouverture = Ouverture.new(ouverture_params)

    respond_to do |format|
      if @ouverture.save
        format.html { redirect_to ouvertures_path, notice: "L'ouverture a été créée avec succès." }
        format.json { render :show, status: :created, location: @ouverture }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ouverture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ouvertures/1 or /ouvertures/1.json
  def update
    respond_to do |format|
      if @ouverture.update(ouverture_params)
        format.html { redirect_to ouvertures_path, notice: "L'ouverture modifiée avec succès." }
        format.json { render :show, status: :ok, location: @ouverture }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ouverture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ouvertures/1 or /ouvertures/1.json
  def destroy
    @ouverture.destroy
    respond_to do |format|
      format.html { redirect_to ouvertures_path, notice: "L'ouverture supprimée avec succès." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ouverture
      @ouverture = Ouverture.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ouverture_params
      params.require(:ouverture).permit(:bloc, :jour, :début, :fin)
    end

    def is_user_authorized
      authorize Ouverture
    end
end
