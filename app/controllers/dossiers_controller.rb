class DossiersController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ show deposer deposer_done ]
  before_action :set_dossier, only: %i[ show edit update destroy envoyer deposer deposer_done valider rejeter relancer archiver ]
  before_action :is_user_authorized

  layout :determine_layout

  # GET /dossiers or /dossiers.json
  def index
    params[:période] ||= AppConstants::PÉRIODE 
    params[:order_by]||= 'dossiers.updated_at'
    params[:column_dossier] ||= session[:column_dossier]
    params[:direction_dossier] ||= session[:direction_dossier]

    if params[:archive].blank?
      @dossiers = Dossier.where.not(workflow_state: "archivé").joins(:intervenant)
    else
      @dossiers = Dossier.all.joins(:intervenant)
    end
    
    unless params[:nom].blank?
      @dossiers = @dossiers.where("intervenants.nom ILIKE ?", "%#{params[:nom].upcase}%")
    end 

    unless params[:période].blank?
      @dossiers = @dossiers.where(période: params[:période])
    end

    unless params[:workflow_state].blank?
      @dossiers = @dossiers.where("dossiers.workflow_state = ?", params[:workflow_state].to_s.downcase)
    end

    if params[:order_by] == 'intervenants.nom'
      @dossiers = @dossiers.reorder(params[:order_by])
    end

    session[:column_dossier] = params[:column_dossier]
    session[:direction_dossier] = params[:direction_dossier]

    @dossiers = @dossiers.reorder(Arel.sql("#{sort_column} #{sort_direction}"))

    respond_to do |format|
      format.html do 
        @dossiers = @dossiers.paginate(page: params[:page], per_page: 20)
      end

      format.xls do
        book = Dossier.to_xls(@dossiers)
        file_contents = StringIO.new
        book.write file_contents # => Now file_contents contains the rendered file output
        filename = 'Dossiers_Candidatures_CEV.xls'
        send_data file_contents.string.force_encoding('binary'), filename: filename 
      end
    end

  end

  # GET /dossiers/1 or /dossiers/1.json
  def show
  end

  # GET /dossiers/new
  def new
    # En cas de changement : changer également dans create
    @intervenants = Intervenant.sans_dossier
    @dossier = Dossier.new
    @dossier.période = AppConstants::PÉRIODE
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
        @intervenants = Intervenant.sans_dossier
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
      format.html { redirect_to dossiers_path, notice: "Dossier supprimé." }
      format.json { head :no_content }
    end
  end

  # 
  # WORKFLOW
  # 

  def envoyer
    @dossier.envoyer_dossier(current_user.id)

    redirect_to @dossier, notice: "Un email vient d'être envoyé à l'intervenant."
  end

  def deposer
    if params[:dossier]
      @dossier.update(dossier_params)
      @dossier.déposer!
      redirect_to deposer_done_dossier_path(@dossier)
    else 
      redirect_to request.referrer, alert: "Il faut ajouter au moins un document"
    end
  end

  def deposer_done
  end

  def valider
    @dossier.valider_dossier(current_user.id)

    redirect_to @dossier, notice: "Dossier validé avec succès. L'intervenant vient d'être informé."
  end

  def relancer
    @dossier.relancer_dossier(current_user.id)

    redirect_to @dossier, notice: "Dossier relancé avec succès. L'intervenant vient d'être informé."
  end

  def rejeter
    if @dossier.rejeter_dossier(current_user.id)
      redirect_to @dossier, notice: "Dossier rejeté. L'intervenant vient d'être informé."
    else
      redirect_to @dossier, alert: "Pour rejeter ce dossier, il faut qu'un document soit en statut 'Non_conforme' !"
    end
  end

  def archiver
    @dossier.archiver_dossier(current_user.id)
    redirect_to @dossier, notice: 'Dossier archivé, les fichiers sources (PDF) des documents validés ont été supprimés'
  end

  def action
    if params[:dossiers_id].present? && params[:action_name].present?
      @dossiers = Dossier.where(id: params[:dossiers_id].keys)
      if @dossiers.pluck(:workflow_state).uniq.many? && params[:action_name] == "Changer d'état"
        redirect_to dossiers_path, alert: 'Veuillez choisir des dossiers avec le même état'
      end
    else
      redirect_to dossiers_path, alert: 'Veuillez choisir des dossiers et une action à appliquer !'
    end
  end

  def action_do
    action_name = params[:action_name]

    @dossiers = Dossier.where(id: params[:dossiers_id]&.keys)

    case action_name
    when "Changer d'état"
      dossiers_modifiés = 0
      method_name = Dossier.state_to_method[params[:workflow_state].to_sym]
      @dossiers.each do |dossier|
        old_state = dossier.workflow_state.to_sym
        if method_name && dossier.respond_to?(method_name)
          dossier.send(method_name, current_user.id)
        end
        new_state = dossier.reload.workflow_state.to_sym

        dossiers_modifiés += 1 if old_state != new_state
      end

      if dossiers_modifiés < @dossiers.count
        flash[:alert] = "#{@dossiers.count - dossiers_modifiés} modifications de dossiers ont échoués et #{dossiers_modifiés} dossiers modifiés avec succès."
      end
    end

    unless flash[:alert]
      flash[:notice] = "Action '#{action_name}' appliquée à #{params.permit![:dossiers_id]&.keys&.size || 0} dossiers.s."
    end
    redirect_to dossiers_path
  end

private
    # Use callbacks to share common setup or constraints between actions.
    def set_dossier
      @dossier = Dossier.find_by(slug: params[:id])
      if @dossier.nil?
        if !user_signed_in? || current_user.intervenant?
          DossierMailer.with(dossier_id: params[:id]).mauvais_url.deliver_now
        end
        redirect_to root_path, alert: "Dossier introuvable"
      end
    end

    # Only allow a list of trusted parameters through.
    def dossier_params
      params.require(:dossier).permit(:intervenant_id, :période, :workflow_state, :mémo,
                                      documents_attributes: [:id, :nom, :fichier, :workflow_state, :commentaire])
    end

    def determine_layout
      'public' unless user_signed_in?
    end

    def sortable_columns
      ['dossiers.période','intervenants.nom','dossiers.workflow_state', 'dossiers.created_at', 'dossiers.updated_at']
    end

    def sort_column
      sortable_columns.include?(params[:column_dossier]) ? params[:column_dossier] : "nom"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction_dossier]) ? params[:direction_dossier] : "asc"
    end

    def is_user_authorized
      authorize @dossier ? @dossier : Dossier
    end
end
