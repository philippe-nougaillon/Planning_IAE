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

    unless params[:salle_id].blank?
      @salles = @salles.where(id:params[:salle_id])
    end

    unless params[:start_date].blank?
      @date = params[:start_date].to_date
    else
      @date = Date.today
    end

    if params[:vue] == 'jour'
      @cours = Cour.where("DATE(cours.debut) =  ?", @date)
                   .where(etat: Cour.etats.values_at(:confirmé, :réalisé))
    else  
      @date_fin = @date + 10.day
      @cours_semaine = Cour.where("cours.debut BETWEEN DATE(?) AND DATE(?)", @date, @date_fin + 1.day)
                           .where(etat: Cour.etats.values_at(:confirmé, :réalisé))
                           .order(:debut) 
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
      unless @heures_dispo_salles.first.zero?
        taux_occupation_matin = @nombre_heures_cours.first * 100 / @heures_dispo_salles.first
      else
        taux_occupation_matin = 0
      end 
      
      unless @heures_dispo_salles.last.zero?
        taux_occupation_soir  = @nombre_heures_cours.last * 100 / @heures_dispo_salles.last
      else  
        taux_occupation_soir  = 0
      end

      @taux_occupation = [taux_occupation_matin, taux_occupation_soir]
    end

    @etendue_horaire = Cour.etendue_horaire

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

  # Afficher les salles disponibles en JSON
  def libres
    salles_dispos_ids = []

    unless params[:id].blank?
      cours = Cour.find(params[:id])
    else
      cours = Cour.new(debut: DateTime.parse(params[:date]), 
                        duree: params[:duree], 
                        formation_id: params[:formation_id], 
                        intervenant_id: params[:intervenant_id],
                        salle_id: Salle.first.id)
    end

    Salle.all.each do |s|
      cours.salle = s 
      if cours.valid?
        salles_dispos_ids << s.id
      end 
    end

    #logger.debug salles_dispos_ids

    respond_to do |format|
      format.json do
        render json: Salle.where(id: salles_dispos_ids).to_json
      end
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
