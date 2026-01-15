class SujetsController < ApplicationController
  before_action :set_sujet, only: %i[ show edit update destroy deposer deposer_done deposer_admin valider rejeter ]
  before_action :is_user_authorized
  skip_before_action :authenticate_user!, only: %i[ show deposer deposer_done]

  # GET /sujets or /sujets.json
  def index
    if params[:archive].blank?
      @sujets = Sujet.where.not(workflow_state: "archivé").joins(:cours)
    else
      @sujets = Sujet.all.joins(:cours)
    end

    @sujets = @sujets.distinct

    if current_user.partenaire_qse?
      @sujets = @sujets.joins(cours: :formation).merge(Formation.partenaire_qse)
      @formations = Formation.partenaire_qse.ordered
    else
      @formations = Formation.for_select
    end

    if params[:gestionnaire].present?
      @sujets = @sujets.joins(:formations).where(formations: {user_id: current_user.id})
    end

    if params[:formation].present?
      formation_id = Formation.find_by(nom: params[:formation]).id
      @sujets = @sujets.where(cours: {formation_id: formation_id})
    end

    if params[:intervenant].present?
      nom_prenom_intervenant = params[:intervenant].split(' ', 2)
      intervenant_id = Intervenant.find_by(nom: nom_prenom_intervenant.first, prenom: nom_prenom_intervenant.last.rstrip).id
      @sujets = @sujets.where(cours: {intervenant_binome_id: intervenant_id})
    end

    if params[:workflow_state].present?
      @sujets = @sujets.where("workflow_state = ?", params[:workflow_state].to_s.downcase)
    end

    @sujets = @sujets.paginate(page: params[:page], per_page: 20)
  end

  # GET /sujets/1 or /sujets/1.json
  def show
    @audits = @sujet.audits.reorder(id: :desc).paginate(page:params[:page], per_page: 10)
  end

  # GET /sujets/new
  def new
    @sujet = Sujet.new
  end

  # GET /sujets/1/edit
  def edit
  end

  # POST /sujets or /sujets.json
  def create
    @sujet = Sujet.new(sujet_params)

    respond_to do |format|
      if @sujet.save
        format.html { redirect_to @sujet, notice: "Sujet créé avec succès." }
        format.json { render :show, status: :created, location: @sujet }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sujet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sujets/1 or /sujets/1.json
  def update
    respond_to do |format|
      if @sujet.update(sujet_params)
        format.html { redirect_to @sujet, notice: "Sujet modifié avec succès.", status: :see_other }
        format.json { render :show, status: :ok, location: @sujet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sujet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sujets/1 or /sujets/1.json
  def destroy
    @sujet.destroy!

    respond_to do |format|
      format.html { redirect_to sujets_path, notice: "Sujet supprimé avec succès.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def deposer
    if params[:sujet]
      if @sujet.valid?
        if @sujet.can_déposer?
          @sujet.update(sujet_params)
          @sujet.déposer!
          DeposerSujetJob.perform_later(@sujet, current_user&.id || 0)
          redirect_to deposer_done_sujet_path(@sujet)
        else
          redirect_to request.referrer, alert: "Le sujet ne peut pas être déposé."
        end
      else
        redirect_to request.referrer, alert: "Il y a une erreur lors de l'enregistrement du sujet."
      end
    else 
      redirect_to request.referrer, alert: "Le sujet est manquant."
    end
  end

  def deposer_done
  end

  def deposer_admin
    if params[:sujet]
      if @sujet.valid?
        if @sujet.can_déposer?
          @sujet.update(sujet_params)
          @sujet.update(workflow_state: "validé")
          redirect_to sujet_path(@sujet), notice: "Sujet enregistré avec succès."
        else
          redirect_to request.referrer, alert: "Le sujet ne peut pas être déposé."
        end
      else
        redirect_to request.referrer, alert: "Il y a une erreur lors de l'enregistrement du sujet."
      end
    else 
      redirect_to request.referrer, alert: "Le sujet est manquant."
    end
  end

  def valider
    if @sujet.valid?
      if @sujet.can_valider?
        @sujet.valider!

        ValidationSujetJob.perform_later(@sujet, current_user&.id)

        redirect_to @sujet, notice: "Sujet validé avec succès."
      elsif @sujet.validé?
        redirect_to @sujet, alert: "Le sujet est déjà validé."
      else
        redirect_to @sujet, alert: "Le sujet ne peut pas être validé."
      end
    else
      redirect_to @sujet, alert: "Le sujet n'est pas valide. Impossible de valider."
    end
  end

  def rejeter
    if @sujet.valid?
      if @sujet.can_rejeter?
        @sujet.rejeter!

        if params[:raisons].present?
          @sujet.message = params[:raisons]
          @sujet.save
        end

        RejeterSujetJob.perform_later(@sujet, current_user&.id)

        redirect_to @sujet, notice: "Sujet rejeté avec succès."
      elsif @sujet.non_conforme?
        redirect_to @sujet, alert: "Le sujet est déjà rejeté."
      else
        redirect_to @sujet, alert: "Le sujet ne peut pas être rejeté."
      end
    else
      redirect_to @sujet, alert: "Le sujet n'est pas valide. Impossible de rejeter."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sujet
      @sujet = Sujet.find_by(slug: params[:id])
      if @sujet.nil?
        redirect_to root_path, alert: "Élément introuvable"
      end
    end

    # Only allow a list of trusted parameters through.
    def sujet_params
      params.require(:sujet).permit(:sujet, :papier, :calculatrice, :ordi_tablette, :téléphone, :dictionnaire, :commentaires)
    end

    def sortable_columns
      ['sujets.workflow_state', 'sujets.created_at', 'sujets.updated_at']
    end

    def sort_column
      sortable_columns.include?(params[:column_sujet]) ? params[:column_sujet] : "updated_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction_sujet]) ? params[:direction_sujet] : "asc"
    end

    def is_user_authorized
      authorize @sujet ? @sujet : Sujet
    end
end
