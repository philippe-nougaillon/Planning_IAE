class JustificatifsController < ApplicationController
  before_action :set_justificatif, only: %i[ show edit update destroy ]

  # GET /justificatifs or /justificatifs.json
  def index
    @justificatifs = Justificatif.all
    @motifs = Justificatif.catégories_humanized

    if params[:etudiant].present?
      etudiant = params[:etudiant].strip
      etudiant_id = Etudiant.find_by(nom: etudiant.split(' ').first, prénom: etudiant.split(' ').last.rstrip).id
      @justificatifs = @justificatifs.where(etudiant_id: etudiant_id)
    end

    if params[:date_debut].present?
      @justificatifs = @justificatifs.where("debut >= DATE(?)", params[:date_debut])
    end

    if params[:date_fin].present?
      @justificatifs = @justificatifs.where("fin <= DATE(?)", params[:date_fin])
    end

    if params[:motif].present?
      @justificatifs = @justificatifs.where(catégorie: params[:motif])
    end

    @justificatifs = @justificatifs.paginate(page: params[:page], per_page: 20)
  end

  # GET /justificatifs/1 or /justificatifs/1.json
  def show
  end

  # GET /justificatifs/new
  def new
    @justificatif = Justificatif.new
  end

  # GET /justificatifs/1/edit
  def edit
  end

  # POST /justificatifs or /justificatifs.json
  def create
    @justificatif = Justificatif.new(justificatif_params)

    respond_to do |format|
      if @justificatif.save
        format.html { redirect_to justificatif_url(@justificatif), notice: "Justificatif was successfully created." }
        format.json { render :show, status: :created, location: @justificatif }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @justificatif.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /justificatifs/1 or /justificatifs/1.json
  def update
    respond_to do |format|
      if @justificatif.update(justificatif_params)
        format.html { redirect_to justificatif_url(@justificatif), notice: "Justificatif was successfully updated." }
        format.json { render :show, status: :ok, location: @justificatif }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @justificatif.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /justificatifs/1 or /justificatifs/1.json
  def destroy
    @justificatif.destroy!

    respond_to do |format|
      format.html { redirect_to justificatifs_url, notice: "Justificatif was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_justificatif
      @justificatif = Justificatif.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def justificatif_params
      params.require(:justificatif).permit(:edusign_id, :nom, :commentaires, :etudiant_id, :edusign_created_at, :accepte_le, :debut, :fin, :file_url)
    end
end
