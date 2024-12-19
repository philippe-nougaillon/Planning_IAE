class DossierEtudiantsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ new create show deposer_done ]
  before_action :set_dossier_etudiant, only: %i[ show edit update destroy deposer_done valider rejeter archiver]
  before_action :is_user_authorized

  # GET /dossier_etudiants or /dossier_etudiants.json
  def index
    params[:order_by] ||= 'updated_at'

    if params[:archive].present?
      @dossier_etudiants = DossierEtudiant.all
    else
      @dossier_etudiants = DossierEtudiant.where.not(workflow_state: "archivé")
    end

    @dossier_etudiants = @dossier_etudiants.order(params[:order_by])

    if params[:search].present?
      @dossier_etudiants = @dossier_etudiants.where("nom ILIKE :search OR prénom ILIKE :search OR email ILIKE :search", {search: "%#{params[:search]}%"})
    end

    if params[:état].present?
      @dossier_etudiants = @dossier_etudiants.where(workflow_state: params[:état])
    end

    respond_to do |format|
      format.html do 
        @dossier_etudiants = @dossier_etudiants.paginate(page: params[:page], per_page: 20)
      end

      format.xls do
        book = DossierEtudiant.to_xls(@dossier_etudiants)
        file_contents = StringIO.new
        book.write file_contents # => Now file_contents contains the rendered file output
        filename = 'Dossiers_Étudiants.xls'
        send_data file_contents.string.force_encoding('binary'), filename: filename 
      end
    end
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
        format.html { redirect_to deposer_done_dossier_etudiant_path(@dossier_etudiant), notice: "Dossier étudiant créé avec succès." }
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

  def deposer_done
  end

  # def deposer
  #   @dossier_etudiant.deposer!
  #   redirect_to @dossier_etudiant, notice: "Dossier étudiant déposé avec succès."
  # end

  def valider
    @dossier_etudiant.valider!
    redirect_to @dossier_etudiant, notice: "Dossier étudiant validé avec succès."
  end

  def rejeter
    @dossier_etudiant.rejeter!
    redirect_to @dossier_etudiant, notice: "Dossier étudiant rejeté avec succès."
  end

  def archiver
    @dossier_etudiant.archiver!
    redirect_to @dossier_etudiant, notice: "Dossier étudiant archivé avec succès."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dossier_etudiant
      @dossier_etudiant = DossierEtudiant.find_by(slug: params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dossier_etudiant_params
      params.require(:dossier_etudiant).permit(:etudiant_id, :nom, :prénom, :certification, :mode_payement, :workflow_state, :formation, :email, :adresse, :téléphone_fixe, :téléphone_mobile, :pièce_identité, :civilité, :date_naissance, :nationalité, :num_secu, :nom_martial, :nom_père, :prénom_père, :prénom_père, :profession_père, :nom_mère, :prénom_mère, :profession_mère, :lettre_de_motivation, :cv )
    end

    def is_user_authorized
      authorize @dossier_etudiant? @dossier_etudiant : DossierEtudiant
    end
end
