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
    params[:column] ||= session[:column]
    params[:direction_formations] ||= session[:direction_formations]
    
    unless params[:archive].blank?
      @formations = Formation.unscoped.where(archive: true)
    else
      @formations = Formation.all
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
    session[:column] = params[:column]
    session[:direction_formations] = params[:direction_formations]

    @formations = @formations.reorder("#{sort_column} #{sort_direction}") 
    
    @all_formations = @formations
    if params[:paginate] == 'pages'
       @formations = @formations.paginate(page: params[:page], per_page: 10)
    end

    @diplomes = Formation.where.not(diplome: nil).select(:diplome).uniq.pluck(:diplome).sort
  end

  # GET /formations/1
  # GET /formations/1.json
  def show
    @salles_habituelles = @formation.cours
                                    .select('cours.id')
                                    .group(:salle_id)
                                    .count(:id)
                                    .sort_by{|k, v| v}
                                    .reverse
                                    .collect{ |x| x.first ? "#{Salle.with_discarded.find(x.first).try(:nom)}x#{ x.last }" : nil }
                                    .select{ |x| !x.nil? }
                                    .join(', ')
  end

  # GET /formations/new
  def new
    @formation = Formation.new
    15.times { @formation.unites.build }
    10.times { @formation.etudiants.build } 
    10.times { @formation.vacations.build }
  end

  # GET /formations/1/edit
  def edit
    5.times { @formation.unites.build }
    5.times { @formation.etudiants.build } 
    10.times { @formation.vacations.build }
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
        format.html { render :new }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_formation
      @formation = Formation.unscoped.find(params[:id])
    end

    def sortable_columns
      ['formations.nom', 'formations.abrg','formations.nbr_etudiants','formations.code_analytique']
    end

    def sort_column
        sortable_columns.include?(params[:column]) ? params[:column] : 'nom'
    end

    def sort_direction
        %w[asc desc].include?(params[:direction_formations]) ? params[:direction_formations] : 'asc'
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def formation_params
      params.require(:formation)
            .permit(:nom, :promo, :diplome, :domaine, :apprentissage, :memo, :nbr_etudiants, :nbr_heures, 
                    :abrg, :user_id, :color, :Forfait_HETD, :hors_catalogue, :nomtauxtd, :code_analytique, :catalogue, :archive, :hss, :courriel,
                    unites_attributes: [:id, :code, :nom, :séances, :heures, :destroy],
                    etudiants_attributes: [:id, :nom, :prénom, :email, :mobile, :_destroy],
                    vacations_attributes: [:id, :date, :intervenant_id, :titre, :qte, :forfaithtd, :commentaires, :_destroy])
    end

    def is_user_authorized
      authorize Formation
    end
end
