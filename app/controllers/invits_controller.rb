class InvitsController < ApplicationController
  before_action :set_invit, only: %i[ show edit update destroy envoyer relancer valider rejeter confirmer archiver ]

  # GET /invits or /invits.json
  def index
    @invits = Invit.all

    unless params[:formation].blank?
      @invits = @invits.joins(:formation).where("formations.id = ?", params[:formation])
    end

    unless params[:intervenant].blank?
      @invits = @invits.where(intervenant_id: params[:intervenant])
    end
   
    unless params[:workflow_state].blank?
      @invits = @invits.where("invits.workflow_state = ?", params[:workflow_state].to_s.downcase)
    end

    @formations = Formation.where(id: @invits.joins(:formation).pluck("formations.id").uniq)
    @intervenants = Intervenant.where(id: @invits.pluck(:intervenant_id).uniq)
    @invits = @invits.paginate(page: params[:page], per_page: 20)
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
  
  # 
  # WORKFLOW
  # 
  # NOUVEAU = 'nouveau'
  # ENVOYE  = 'envoyé'
  # RELANCE1= 'relancé 1 fois'
  # RELANCE2= 'relancé 2 fois'
  # RELANCE3= 'relancé 3 fois'
  # VALIDE  = 'validé'
  # REJETE  = 'rejeté'
  # CONFIRME= 'confirmé'
  # ARCHIVE = 'archive'

  def envoyer
    @invit.envoyer!
    #Mailer.with(dossier: @dossier).dossier_email.deliver_later
    redirect_to invits_path, notice: "Un email va être envoyé à l'intervenant"
  end

  def valider
    @invit.valider!
    #Mailer.with(dossier: @dossier).valider_email.deliver_later

    redirect_to invits_path, notice: "Invitation validée avec succès. L'intervenant va en être informé."
  end

  def relancer
    @invit.relancer!
    #Mailer.with(dossier: @dossier).dossier_email.deliver_later
    redirect_to invits_path, notice: "Invitation relancée avec succès. L'intervenant va en être informé."
  end

  def rejeter
    @dossier.rejeter!
    # Mailer.with(dossier: @dossier).rejeter_email.deliver_later
    redirect_to invits_path, notice: "Invitation rejetée. L'intervenant va en être informé."
  end

  def confirmer
    @invit.confirmer!
    redirect_to invits_path, notice: 'Invitation confirmée'
  end

  def archiver
    @invit.archiver!
    redirect_to invits_path, notice: 'Invitation archivée'
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
