# ENCODING: UTF-8

class SallesController < ApplicationController
  before_action :set_salle, only: [:show, :edit, :update, :destroy]

  # GET /salles
  # GET /salles.json
  def index
    authorize Salle
    @salles = Salle.order(:nom)

    unless params[:salle_id].blank?
      @salles = @salles.where(id:params[:salle_id])
    end
  end

  def occupation
    params[:vue] ||= 'jour'
    @salles = Salle.reorder(:bloc, :nom)

    unless session[:start_date].blank?
      params[:start_date] ||= session[:start_date]
    else
      params[:start_date] ||= Date.today
    end

    #if params[:vue] == 'week'
    #  params[:start_date] = Date.parse(params[:start_date]).beginning_of_week(start_day = :monday).to_s
    #end  

    unless params[:salle_id].blank?
      @salles = @salles.where(id:params[:salle_id])
    end

    unless params[:start_date].blank?
      @date = params[:start_date].to_date
    else
      @date = Date.today
    end

    if user_signed_in?
      #
      # Calcul du taux d'occupation
      #

      # salles concernées
      @salles_dispo = Salle.salles_de_cours.count
      @salles_dispo_samedi = Salle.salles_de_cours_du_samedi.count

      # cumul les heures de cours du jour et du soir
      @nombre_heures_cours = [Cour.cumul_heures(@date).first, 
                              Cour.cumul_heures(@date).last]

      # amplitude 
      @nb_heures_journée = Salle.nb_heures_journée
      @nb_heures_soirée = Salle.nb_heures_soirée

      # nombre d'heures salles
      @heures_dispo_salles = [@salles_dispo * @nb_heures_journée, 
                              @salles_dispo_samedi * @nb_heures_soirée] 

      # taux d'occupation  
      @taux_occupation = [(@nombre_heures_cours.first * 100 / @heures_dispo_salles.first),
                           (@nombre_heures_cours.last * 100 / @heures_dispo_salles.last)]
    end

    session[:start_date] = params[:start_date]
  end

  # GET /salles/1
  # GET /salles/1.json
  def show
    authorize Salle
    @audits = Audited::Audit
                  .where(auditable_type: 'Cour')
                  .where("audited_changes like '%salle_id%'")
                  .order('id DESC')
                  .limit(5000)

  end

  # GET /salles/new
  def new
    authorize Salle
    @salle = Salle.new
  end

  # GET /salles/1/edit
  def edit
    authorize Salle
  end

  # POST /salles
  # POST /salles.json
  def create
    authorize Salle
    @salle = Salle.new(salle_params)

    respond_to do |format|
      if @salle.save
        format.html { redirect_to @salle, notice: 'Salle ajoutée.' }
        format.json { render :show, status: :created, location: @salle }
      else
        format.html { render :new }
        format.json { render json: @salle.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /salles/1
  # PATCH/PUT /salles/1.json
  def update
    authorize Salle
    respond_to do |format|
      if @salle.update(salle_params)
        format.html { redirect_to @salle, notice: 'Salle modifiée.' }
        format.json { render :show, status: :ok, location: @salle }
      else
        format.html { render :edit }
        format.json { render json: @salle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /salles/1
  # DELETE /salles/1.json
  def destroy
    authorize Salle
    @salle.destroy
    respond_to do |format|
      format.html { redirect_to salles_url, notice: 'Salle supprimé.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_salle
      @salle = Salle.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def salle_params
      params.require(:salle).permit(:nom, :places, :bloc)
    end
end
