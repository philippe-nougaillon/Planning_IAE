# encoding: UTF-8

class EtudiantsController < ApplicationController
  before_action :set_etudiant, only: [:show, :edit, :update, :destroy]
  before_action :is_user_authorized

  # GET /etudiants
  # GET /etudiants.json
  def index

    params[:column] ||= session[:column]
    params[:direction_etudiants] ||= session[:direction_etudiants]
    params[:paginate] ||= 'pages'

    @etudiants = Etudiant.all

    unless params[:search].blank?
      @etudiants = @etudiants.where("LOWER(nom) like :search OR LOWER(prénom) like :search OR LOWER(email) like :search", {search: "%#{params[:search]}%".downcase})
    end

    unless params[:formation_id].blank?
      @etudiants = @etudiants.where(formation_id:params[:formation_id])
    end

    session[:column] = params[:column]
    session[:direction_etudiants] = params[:direction_etudiants]
    
    @etudiants = @etudiants.reorder("#{sort_column} #{sort_direction}")
    if (params[:paginate] == 'pages')
      @etudiants = @etudiants.paginate(page: params[:page], per_page: 20)
    end
  end

  # GET /etudiants/1
  # GET /etudiants/1.json
  def show
    @user = @etudiant.linked_user
  end

  # GET /etudiants/new
  def new
    @etudiant = Etudiant.new
    @etudiant.workflow_state = "étudiant"
  end

  # GET /etudiants/1/edit
  def edit
  end

  # POST /etudiants
  # POST /etudiants.json
  def create
    @etudiant = Etudiant.new(etudiant_params)

    respond_to do |format|
      if @etudiant.save
        if params[:notify]
          # Création du compte d'accès (user) et envoi du mail de bienvenue
          user = User.new(nom: @etudiant.nom, prénom: @etudiant.prénom, email: @etudiant.email, mobile: @etudiant.mobile, password: SecureRandom.hex(10))
          if user.valid?
            user.save
            mailer_response = EtudiantMailer.welcome_student(user).deliver_now
            MailLog.create(user_id: current_user.id, message_id: mailer_response.message_id, to: @etudiant.email, subject: "Nouvel accès étudiant")
          end
        end
        format.html { redirect_to @etudiant, notice: "Etudiant créé avec succès. #{'Accès créé, étudiant informé' if params[:notify] }" }
        format.json { render :show, status: :created, location: @etudiant }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @etudiant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /etudiants/1
  # PATCH/PUT /etudiants/1.json
  def update
    respond_to do |format|
      if @etudiant.update(etudiant_params)
        format.html { redirect_to @etudiant, notice: 'Etudiant modifié avec succès.' }
        format.json { render :show, status: :ok, location: @etudiant }
      else
        format.html { render :edit }
        format.json { render json: @etudiant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /etudiants/1
  # DELETE /etudiants/1.json
  def destroy
    @etudiant.destroy
    respond_to do |format|
      format.html { redirect_to etudiants_path, notice: 'Etudiant supprimé avec succès' }
      format.json { head :no_content }
    end
  end

  def action
    unless params[:etudiants_id].blank? or params[:action_name].blank?
      @etudiants = Etudiant.where(id: params[:etudiants_id].keys)

      case params[:action_name]
      when "Changer de formation"
      end
    else
      redirect_to etudiants_path, alert:'Veuillez choisir des étudiants et une action à appliquer !'
    end
  end

  def action_do
    action_name = params[:action_name]

    @etudiants = Etudiant.where(id: params[:etudiants_id].keys)

    case action_name
    when "Changer de formation"
      @etudiants.each do |etudiant|
        etudiant.formation_id = params[:formation_id].to_i
        etudiant.save
      end
    when "Supprimer"
      @etudiants.each do |etudiant|
        etudiant.destroy
      end
    end

    unless flash[:alert]
      flash[:notice] = "Action '#{action_name}' appliquée à #{params.permit![:etudiants_id].keys.size} étudiant.s."
    end
    redirect_to cours_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_etudiant
      @etudiant = Etudiant.find(params[:id])
    end

    def sortable_columns
      ['etudiants.nom', 'etudiants.prénom', 'etudiants.date_de_naissance', 'etudiants.workflow_state', 'etudiants.nom_entreprise', 'etudiants.updated_at']
    end

    def sort_column
        sortable_columns.include?(params[:column]) ? params[:column] : "etudiants.nom"
    end

    def sort_direction
        %w[asc desc].include?(params[:direction_etudiants]) ? params[:direction_etudiants] : "asc"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def etudiant_params
      params.require(:etudiant)
            .permit(:formation_id, :nom, :prénom, :email, :mobile, :civilité, :nom_marital, :date_de_naissance, 
                    :lieu_naissance, :pays_naissance, :nationalité, :adresse, :cp, :ville, :dernier_ets, 
                    :dernier_diplôme, :cat_diplôme, :num_sécu, 
                    :num_apogée, :poste_occupé, :nom_entreprise, :adresse_entreprise, :cp_entreprise, :ville_entreprise,
                    :workflow_state, :table)
    end

    def is_user_authorized
      authorize Etudiant
    end
end
