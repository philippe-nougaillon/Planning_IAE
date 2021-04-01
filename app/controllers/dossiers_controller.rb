class DossiersController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ show deposer]
  before_action :set_dossier, only: %i[ show edit update destroy envoyer deposer valider rejeter archiver ]

  # GET /dossiers or /dossiers.json
  def index
    authorize Dossier

    @dossiers = Dossier.all

    unless params[:nom].blank?
      @dossiers = @dossiers.joins(:intervenant).where("intervenants.nom ILIKE ?", "%#{params[:nom].upcase}%")
    end 

    unless params[:période].blank?
      @dossiers = @dossiers.where(période: params[:période])
    end

    unless params[:workflow_state].blank?
      @dossiers = @dossiers.where("dossiers.workflow_state = ?", params[:workflow_state].to_s.downcase)
    end

    @dossiers = @dossiers.paginate(page: params[:page], per_page: 20)
  end

  # GET /dossiers/1 or /dossiers/1.json
  def show
    #authorize @dossier
  end

  # GET /dossiers/new
  def new
    @dossier = Dossier.new
    3.times { @dossier.documents.build }
  end

  # GET /dossiers/1/edit
  def edit
  end

  # POST /dossiers or /dossiers.json
  def create
    @dossier = Dossier.new(dossier_params)

    respond_to do |format|
      if @dossier.save
        format.html { redirect_to @dossier, notice: "Nouveau dossier créé avec succès" }
        format.json { render :show, status: :created, location: @dossier }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @dossier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dossiers/1 or /dossiers/1.json
  def update
    respond_to do |format|
      if @dossier.update(dossier_params)
        format.html { redirect_to @dossier, notice: "Dossier modifié." }
        format.json { render :show, status: :ok, location: @dossier }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @dossier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dossiers/1 or /dossiers/1.json
  def destroy
    @dossier.destroy
    respond_to do |format|
      format.html { redirect_to dossiers_url, notice: "Dossier supprimé." }
      format.json { head :no_content }
    end
  end


  # Actions du Workflow
  def envoyer
    @dossier.envoyer!
    redirect_to dossiers_url, notice: "Un mail va bientôt être envoyé à l'intervant"
  end

  def deposer
    @dossier.déposer!
  end

  def valider
    @dossier.valider!
    redirect_to dossiers_url, notice: 'Dossier validé'
  end

  def rejeter
    @dossier.rejeter!
    redirect_to dossiers_url, notice: 'Dossier rejeté'
  end

  def archiver
    @dossier.archiver!
    redirect_to dossiers_url, notice: 'Dossier archivé'
  end

private
    # Use callbacks to share common setup or constraints between actions.
    def set_dossier
      @dossier = Dossier.find_by(slug: params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dossier_params
      params.require(:dossier).permit(:intervenant_id, :période, :workflow_state, 
                                      documents_attributes: [:id, :nom, :fichier])
    end
end
