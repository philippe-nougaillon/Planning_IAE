class InvitsController < ApplicationController
  before_action :set_invit, only: %i[ show edit update destroy ]

  # GET /invits or /invits.json
  def index
    @invits = Invit.all
  end

  # GET /invits/1 or /invits/1.json
  def show
  end

  # GET /invits/new
  def new
    @invit = Invit.new
  end

  # GET /invits/1/edit
  def edit
  end

  # POST /invits or /invits.json
  def create
    @invit = Invit.new(invit_params)

    respond_to do |format|
      if @invit.save
        format.html { redirect_to @invit, notice: "Invit was successfully created." }
        format.json { render :show, status: :created, location: @invit }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invits/1 or /invits/1.json
  def update
    respond_to do |format|
      if @invit.update(invit_params)
        format.html { redirect_to @invit, notice: "Invit was successfully updated." }
        format.json { render :show, status: :ok, location: @invit }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invits/1 or /invits/1.json
  def destroy
    @invit.destroy
    respond_to do |format|
      format.html { redirect_to invits_url, notice: "Invit was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invit
      @invit = Invit.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def invit_params
      params.require(:invit).permit(:cour_id, :intervenant_id, :msg, :workflow_state)
    end
end
