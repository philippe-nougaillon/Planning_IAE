class InvitsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[show validation valider rejeter]
  before_action :set_invit, only: %i[ show edit update destroy relancer valider rejeter confirmer archiver validation]
  before_action :is_user_authorized

  # GET /invits or /invits.json
  def index

    params[:sort_by] ||= 'MàJ'
    @invits = Invit
                .where(user_id: current_user.id)
                .where.not("invits.workflow_state = 'non_retenue'") 

    unless params[:formation].blank?
      @invits = @invits.joins(:formation).where("formations.id = ?", params[:formation])
    end

    unless params[:intervenant].blank?
      @invits = @invits.where(intervenant_id: params[:intervenant])
    end

    unless params[:start_date].blank?
      @invits = @invits.joins(:cour).where("DATE(cours.debut) >= ?", params[:start_date])
    end

    unless params[:workflow_state].blank?
      @invits = @invits.where("invits.workflow_state = ?", params[:workflow_state].to_s.downcase)
    end

    unless params[:sort_by].blank?
      @invits = @invits.order(:updated_at) if params[:sort_by] == 'MàJ'
      @invits = @invits.joins(:cour).reorder('cours.debut') if params[:sort_by] == 'Date'
    end

    unless params[:archive].blank?
      @invits = Invit.where("invits.workflow_state = 'non_retenue'")   
    end

    unless params[:cours_id].blank?
      @invits = @invits.where(cour_id: params[:cours_id].to_i)
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
        format.html { redirect_to @invit, notice: "L'invitation a bien été créée." }
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
        format.html { redirect_to @invit, notice: "L'invitation a bien été modifiée." }
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
      format.html { redirect_to invits_path, notice: "L'invitation a bien été supprimée." }
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
    when "Supprimer"
      invits.each do |invit| 
        invit.destroy
        count += 1
      end
    end
    flash[:notice] = "#{count} invitation.s modifiée.s"  

    redirect_to invits_path
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
    if user_signed_in?
      redirect_to invits_path, notice: "Invitation mise à jour avec succès"
    else
      redirect_to invitations_intervenant_path(@invit.intervenant), notice: "Invitation mise à jour avec succès."
    end
  end

  def rejeter
    @invit.rejeter!
    redirect_to invitations_intervenant_path(@invit.intervenant), notice: "Invitation mise à jour avec succès."
  end

  def confirmer

    # attribuer le cours
    cours = @invit.cour
    cours.intervenant = @invit.intervenant
    cours.code_ue = (@invit.ue ? Unite.find(@invit.ue).code : nil)
    cours.nom = @invit.nom
    cours.valid?
    if cours.errors.full_messages == ["Cours a des invitations en cours !"]
      @invit.confirmer!
      puts '[DEBUG] Confirmé'
  
      # fermer les invitations en cours avant d'attribuer le cours
      Invit.where(cour_id: @invit.cour_id).where.not(id: @invit.id).each do |invit|
        invit.archiver!
      end
      puts '[DEBUG] Archivés'

      # Force l'enregistrement du nouvel intervenant
      cours.save(validate: false)
      puts "{DEBUG] Intervenant enregistré"
  
      flash[:notice] = "Invitation confirmée. Intervenant affecté."
    else
      flash[:error] = "L'intervenant n'a pas pu être modifié. #{ cours.errors.full_messages }"
    end
    redirect_to invits_path
  end

  def validation
    @invit.update(reponse: params[:reponse])
    case params[:commit]
    when 'Disponible'
      @invit.valider!
      flash[:notice] = "Invitation mise à jour avec succès."
    when 'Pas disponible'
      @invit.rejeter!
      flash[:notice] = "Invitation mise à jour avec succès."
    end
    redirect_to invitations_intervenant_path(@invit.intervenant)
  end

  def archiver
    @invit.archiver!
    redirect_to invits_path, notice: 'Invitation archivée'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invit
      @invit = Invit.find_by(slug: params[:id])
    end

    # Only allow a list of trusted parameters through.
    def invit_params
      params.require(:invit).permit(:cour_id, :intervenant_id, :msg, :workflow_state)
    end

    def is_user_authorized
      authorize Invit
    end
end
