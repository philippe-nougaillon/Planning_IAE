class InvitsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ show validation]
  before_action :set_invit, only: %i[ show edit update destroy relancer valider rejeter confirmer archiver validation]

  # GET /invits or /invits.json
  def index
    authorize Invit

    params[:sort_by] ||= 'Date'
    @invits = Invit.where.not("invits.workflow_state = 'archivée'") 

    unless params[:formation].blank?
      @invits = @invits.joins(:formation).where("formations.id = ?", params[:formation])
    end

    unless params[:intervenant].blank?
      @invits = @invits.where(intervenant_id: params[:intervenant])
    end

    unless params[:workflow_state].blank?
      @invits = @invits.where("invits.workflow_state = ?", params[:workflow_state].to_s.downcase)
    end

    unless params[:sort_by].blank?
      @invits = @invits.order(:updated_at) if params[:sort_by] == 'MàJ'
      @invits = @invits.joins(:cour).reorder('cours.debut') if params[:sort_by] == 'Date'
    end

    unless params[:archive].blank?
      @invits = Invit.where("invits.workflow_state = 'archivée'")   
    end

    @formations = Formation.where(id: @invits.joins(:formation).pluck("formations.id").uniq)
    @intervenants = Intervenant.where(id: @invits.pluck(:intervenant_id).uniq)
    @invits = @invits.paginate(page: params[:page], per_page: 20)
  end

  # GET /invits/1 or /invits/1.json
  def show
    @jour = @invit.cour.debut.to_date
    @cours = @invit.intervenant.cours.where("DATE(cours.debut) = ?", @jour)
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
    #@invit.destroy
    respond_to do |format|
      format.html { redirect_to invits_url, notice: "Invit was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  
  def action
    return unless params[:invits_id]

    invits = Invit.where(id: params[:invits_id].keys)
    count = 0

    case params[:action_name]
    when "Relancer"
      invits.each do |invit|
        if invit.can_relancer? 
          invit.relancer! 
          count += 1
        end
      end
    when "Confirmer"
    when "Archiver"
      invits.each do |invit| 
        if invit.can_archiver?
          invit.archiver!
          count += 1
        end 
      end
    end
    flash[:notice] = "#{count} invitation.s modifiée.s"  

    redirect_to invits_url
  end


  # 
  # WORKFLOW
  # 
  
  # def envoyer
  #   @invit.envoyer!
  #   redirect_to invits_path, notice: "Un email va être envoyé à l'intervenant"
  # end

  def relancer
    @invit.relancer!
    InvitMailer.with(invit: @invit).envoyer_invitation.deliver_now
    redirect_to invits_path, notice: "Invitation relancée avec succès."
  end

  def valider
    @invit.valider!
    InvitMailer.with(invit: @invit).validation_invitation.deliver_now
    redirect_to invitations_intervenant_path(@invit.intervenant), notice: "Invitation mise à jour avec succès."
  end

  def rejeter
    @invit.rejeter!
    InvitMailer.with(invit: @invit).rejet_invitation.deliver_now
    redirect_to invitations_intervenant_path(@invit.intervenant), notice: "Invitation mise à jour avec succès."
  end

  def confirmer
    @invit.confirmer!
    @invit.cour.update(intervenant: @invit.intervenant, ue: Unite.find(@invit.ue).nom, nom: @invit.nom)
    #passer toutes les invits du même cours en archivé
    Invit.where(cour_id: @invit.cour_id).where.not(id: @invit.id).each do |invit|
      invit.archiver!
    end
    InvitMailer.with(invit: @invit).confirmation_invitation.deliver_now
    redirect_to invits_path, notice: 'Invitation confirmée. Intervenant affecté.'
  end

  def archiver
    @invit.archiver!
    redirect_to invits_path, notice: 'Invitation archivée'
  end

  def validation
    @invit.update(reponse: params[:reponse])
    case params[:commit]
    when 'Disponible'
      @invit.valider!
      InvitMailer.with(invit: @invit).validation_invitation.deliver_now
      flash[:notice] = "Invitation mise à jour avec succès."
    when 'Pas disponible'
      @invit.rejeter!
      InvitMailer.with(invit: @invit).rejet_invitation.deliver_now
      flash[:notice] = "Invitation mise à jour avec succès."
    end
    redirect_to invitations_intervenant_path(@invit.intervenant)
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invit
      @invit = Invit.friendly.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def invit_params
      params.require(:invit).permit(:cour_id, :intervenant_id, :msg, :workflow_state)
    end
end
