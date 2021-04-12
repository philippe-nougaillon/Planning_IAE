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

  # 
  # WORKFLOW
  # 

  def envoyer
    # Passe le dossier à l'état 'Envoyé'
    @dossier.envoyer!

    # Informe l'intervenant
    DossierMailer.with(dossier: @dossier).dossier_email.deliver_later

    redirect_to @dossier, notice: "Un email va être envoyé à l'intervenant"
  end

  def deposer
    @dossier.déposer!
  end

  def valider
    # Valide tous les documents
    @dossier.documents.each do | doc |
      doc.valider! if doc.can_valider?
    end

    # Passe le dossier à l'état 'Validé'
    @dossier.valider!

    # Informe l'intervenant
    DossierMailer.with(dossier: @dossier).valider_email.deliver_later

    redirect_to @dossier, notice: "Dossier validé avec succès. L'intervenant va en être informé."
  end

  def rejeter
    # Vérifier qu'il y a au moins un document à l'état rejeté
    rejeter = false
    @dossier.documents.each do | doc |
      rejeter = true if doc.rejeté?
    end
    
    if rejeter
      # Passe le dossier à l'état 'Rejeté'
      @dossier.rejeter!

      # Informe l'intervenant
      DossierMailer.with(dossier: @dossier).rejeter_email.deliver_later

      redirect_to @dossier, notice: "Dossier rejeté. L'intervenant va en être informé."
    else
      redirect_to @dossier, alert: "Pour rejeter ce dossier, il faut qu'un document soit en statut 'Rejeté' !"
    end
  end

  def archiver
    @dossier.documents.each do | doc |
      if doc.validé?
        doc.fichier.purge
        doc.archiver!
      elsif doc.rejeté?
        doc.destroy
      end
    end
    @dossier.archiver!
    redirect_to @dossier, notice: 'Dossier archivé, les fichiers sources (PDF) des documents validés ont été supprimés'
  end

private
    # Use callbacks to share common setup or constraints between actions.
    def set_dossier
      @dossier = Dossier.find_by(slug: params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dossier_params
      params.require(:dossier).permit(:intervenant_id, :période, :workflow_state, :mémo,
                                      documents_attributes: [:id, :nom, :fichier, :workflow_state, :commentaire])
    end
end
