class PresencesController < ApplicationController
  before_action :set_presence, only: %i[ show edit update destroy ]

  # GET /presences or /presences.json
  def index
    @presences = Presence.ordered
  end

  # GET /presences/1 or /presences/1.json
  def show
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_presence
      @presence = Presence.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def presence_params
      params.require(:presence).permit(:cour_id, :user_id, :signature)
    end
end
