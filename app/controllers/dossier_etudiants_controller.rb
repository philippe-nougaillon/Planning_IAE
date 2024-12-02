class DossierEtudiantsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ new create show ]
  before_action :set_dossier_etudiant, only: %i[ show edit update destroy ]

  # GET /dossier_etudiants or /dossier_etudiants.json
  def index
    @dossier_etudiants = DossierEtudiant.all
  end

  # GET /dossier_etudiants/1 or /dossier_etudiants/1.json
  def show
  end

  # GET /dossier_etudiants/new
  def new
    @dossier_etudiant = DossierEtudiant.new
    @etudiant = Etudiant.new
  end

  # GET /dossier_etudiants/1/edit
  def edit
  end

  # POST /dossier_etudiants or /dossier_etudiants.json
  def create
    @dossier_etudiant = DossierEtudiant.new(dossier_etudiant_params)

    respond_to do |format|
      if @dossier_etudiant.save
        format.html { redirect_to dossier_etudiant_url(@dossier_etudiant), notice: "Dossier étudiant créé avec succès." }
        format.json { render :show, status: :created, location: @dossier_etudiant }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @dossier_etudiant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dossier_etudiants/1 or /dossier_etudiants/1.json
  def update
    respond_to do |format|
      if @dossier_etudiant.update(dossier_etudiant_params)
        format.html { redirect_to dossier_etudiant_url(@dossier_etudiant), notice: "Dossier étudiant modifié avec succès." }
        format.json { render :show, status: :ok, location: @dossier_etudiant }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @dossier_etudiant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dossier_etudiants/1 or /dossier_etudiants/1.json
  def destroy
    @dossier_etudiant.destroy!

    respond_to do |format|
      format.html { redirect_to dossier_etudiants_url, notice: "Dossier étudiant supprimé avec succès." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dossier_etudiant
      @dossier_etudiant = DossierEtudiant.find_by(slug: params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dossier_etudiant_params
      params.require(:dossier_etudiant).permit(:etudiant_id, :mode_payement, :workflow_state)
    end
end
