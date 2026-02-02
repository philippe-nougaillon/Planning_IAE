# ENCODING: UTF-8

class FormationsController < ApplicationController
  before_action :set_formation, only: [:show, :edit, :update, :destroy]
  before_action :is_user_authorized

  # GET /formations
  # GET /formations.json
  def index
    params[:nom] ||= session[:nom]  # ???? 
    params[:catalogue] ||= 'yes'
    params[:paginate] ||= 'pages'
    params[:column_formation] ||= session[:column_formation]
    params[:direction_formation] ||= session[:direction_formation]
    
    unless params[:archive].blank?
      @formations = Formation.where(archive: true)
    else
      @formations = Formation.not_archived
    end

    unless params[:nom].blank?
      @formations = @formations.where("LOWER(nom) like :search OR LOWER(abrg) like :search OR LOWER(code_analytique) like :search", {search: "%#{params[:nom]}%".downcase})
    end

    unless params[:apprentissage].blank?
      @formations = @formations.where(apprentissage: true)
    end

    unless params[:promo].blank?
      @formations = @formations.where(promo:params[:promo])
    end

    case params[:catalogue]
    when 'yes'
      @formations = @formations.where(hors_catalogue: false)
    when 'no'
      @formations = @formations.where(hors_catalogue: true)
    when 'all'
    end

    session[:nom] = params[:nom] # ???? 
    session[:column_formation] = params[:column_formation]
    session[:direction_formation] = params[:direction_formation]

    @formations = @formations.reorder(Arel.sql("#{sort_column} #{sort_direction}"))
    
    @all_formations = @formations
    if params[:paginate] == 'pages'
       @formations = @formations.paginate(page: params[:page], per_page: 10)
    end
  end

  # GET /formations/1
  # GET /formations/1.json
  def show
    # TODO : optimiser en scenic_view
    @salles_habituelles_ids = @formation.cours
                                    .joins(:salle)
                                    .where("salles.bloc != 'Z'")
                                    .select('cours.id')
                                    .group(:salle_id)
                                    .count(:id)
                                    .sort_by{|k, v| v}
                                    .reverse
                                    .first(5)

    @average_count = 0
    @salles_habituelles_ids.map{|x| @average_count += x.last.to_i / 5}
  end

  # GET /formations/new
  def new
    @formation = Formation.new
  end

  # GET /formations/1/edit
  def edit
  end

  # POST /formations
  # POST /formations.json
  def create
    @formation = Formation.new(formation_params)

    respond_to do |format|
      if @formation.save
        format.html { redirect_to @formation, notice: 'Formation ajoutée' }
        format.json { render :show, status: :created, location: @formation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @formation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /formations/1
  # PATCH/PUT /formations/1.json
  def update
    respond_to do |format|
      if @formation.update(formation_params)
        format.html { redirect_to @formation, notice: 'Formation modifiée' }
        format.json { render :show, status: :ok, location: @formation }
      else
        format.html { render :edit }
        format.json { render json: @formation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /formations/1
  # DELETE /formations/1.json
  def destroy
    @formation.destroy
    respond_to do |format|
      format.html { redirect_to formations_path, notice: 'Formation supprimée.' }
      format.json { head :no_content }
    end
  end

  def action
    unless params[:formations_id].blank? or params[:action_name].blank?
      @formations = Formation.where(id: params[:formations_id].keys).ordered
    else
      redirect_to formations_path, alert:'Veuillez choisir des formations et une action à appliquer !'
    end
  end

  def action_do
    action_name = params[:action_name]

    @formations = Formation.where(id: params[:formations_id]&.keys)
    formations_modifiées_count = 0

    case action_name
    when "Archiver formation et désactiver les étudiants"
      @formations.each do |formation|
        formation.archive = true
        if formation.save
          formations_modifiées_count += 1
        else
          # Vérifie si la seule erreur est "User doit exister"
          if formation.errors.details[:user].any? { |e| e[:error] == :blank } && formation.errors.size == 1
            # Corrige le user_id par un gestionnaire par défaut
            formation.user_id = ENV['GESTIONNAIRE_PLACEHOLDER']
            if formation.save
              formations_modifiées_count += 1
            end
          end
        end

        if formation.persisted? && formation.archive?
          formation.etudiants.each do |etudiant|
            if user = etudiant.linked_user
              user.discard
            end
          end
        end
      end
    when "Changer de gestionnaire"
      @formations.each do |formation|
        formation.user_id = params[:user_id].to_i
        if formation.save
          formations_modifiées_count += 1
        end
      end
    when "Synchroniser sur Edusign"
      @formations.each do |formation|
        formation.send_to_edusign = true
        if formation.save
          formations_modifiées_count += 1
        end
      end
    end
    
    if formations_modifiées_count < @formations.count
      flash[:alert] = "#{@formations.count - formations_modifiées_count} modifications ont échouées et #{formations_modifiées_count} formations modifiées avec succès."
    else
      flash[:notice] = "Action '#{action_name}' appliquée à #{params.permit![:formations_id]&.keys&.size || 0} formation.s."
    end
    redirect_to formations_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_formation
      @formation = Formation.find(params[:id])
    end

    def sortable_columns
      ['formations.nom', 'formations.abrg','formations.nbr_etudiants','formations.code_analytique', 'formations.edusign_id']
    end

    def sort_column
      sortable_columns.include?(params[:column_formation]) ? params[:column_formation] : 'formations.nom'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction_formation]) ? params[:direction_formation] : 'asc'
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def formation_params
      params.require(:formation)
            .permit(:nom, :promo, :diplome, :domaine, :apprentissage, :memo, :nbr_etudiants, :nbr_heures, 
                    :abrg, :user_id, :color, :Forfait_HETD, :hors_catalogue, :nomtauxtd, :code_analytique, :catalogue, :archive, :hss, :courriel, :send_to_edusign,
                    unites_attributes: [:id, :code, :nom, :séances, :heures, :destroy],
                    etudiants_attributes: [:id, :nom, :prénom, :civilité, :email, :mobile, :_destroy],
                    vacations_attributes: [:id, :date, :intervenant_id, :titre, :qte, :forfaithtd, :commentaires, :vacation_activite_id, :_destroy],
                    responsabilites_attributes: [:id, :debut, :intervenant_id, :titre, :heures, :commentaires, :activite_id, :_destroy])
    end

    def is_user_authorized
      authorize Formation
    end
end
