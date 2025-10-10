# ENCODING: UTF-8

class SallesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ occupation ]
  before_action :set_salle, only: [:show, :edit, :update, :destroy]
  before_action :is_user_authorized, except: %i[ libres ]

  # GET /salles
  # GET /salles.json
  def index
    @salles = Salle.order(:nom)

    unless params[:salle_id].blank?
      @salles = @salles.where(id:params[:salle_id])
    end
  end

  def occupation
    params[:vue] ||= 'jour'
    
    @salles = Salle.all

    unless session[:start_date].blank?
      params[:start_date] ||= session[:start_date]
    else
      params[:start_date] ||= Date.today
    end

    unless params[:bloc].blank?
      @salles = @salles.where(bloc: params[:bloc])
    end

    unless params[:salle_id].blank?
      @salles = @salles.where(id: params[:salle_id])
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
    @audits = Audited::Audit
                  .where(auditable_type: 'Cour')
                  .where("audited_changes like '%salle_id%'")
                  .order('id DESC')
                  .limit(10000)

    @taux_occupation = {}
    # 11 heures par jour * 5.5j (soit une semaine) * 52 semaines - 8 semaines de fermeture </i>
    sum_occupation_max = (11 * 5.5) * (52 - 8)
    (2017..2025).each do |year|
      sum_occupation = @salle.cours.where("DATE(cours.debut) BETWEEN ? AND ?", "#{year}-09-01", "#{year+1}-07-01").réalisé.sum(:duree).to_i
      @taux_occupation[year] =  (sum_occupation / sum_occupation_max * 100).to_i
    end

    qrcode = RQRCode::QRCode.new("https://planning.iae-paris.com/?salle_id=#{@salle.id}")

    @qrcode_svg = qrcode.as_svg(
          color: "000",
          shape_rendering: "crispEdges",
          module_size: 11,
          standalone: true,
          use_path: true,
          viewbox: "20 20"
    )
  end

  # GET /salles/new
  def new
    @salle = Salle.new
  end

  # GET /salles/1/edit
  def edit

  end

  # POST /salles
  # POST /salles.json
  def create
    @salle = Salle.new(salle_params)

    respond_to do |format|
      if @salle.save
        format.html { redirect_to @salle, notice: 'Salle ajoutée.' }
        format.json { render :show, status: :created, location: @salle }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @salle.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /salles/1
  # PATCH/PUT /salles/1.json
  def update
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
    @salle.destroy
    respond_to do |format|
      format.html { redirect_to salles_path, notice: 'Salle supprimée.' }
      format.json { head :no_content }
    end
  end

  # Afficher les salles disponibles en JSON
  def libres
    salles_dispos_ids = []
    cours = nil
    @salles = Salle.all

    if current_user && current_user.partenaire_qse?
      @salles = @salles.where(nom: ["ICP 1", "ICP 2"])
    end

    if !(params[:id].blank?)
      cours = Cour.find(params[:id])
    elsif !(params[:date].blank? || params[:duree].blank? || params[:formation_id].blank? || params[:intervenant_id].blank?)
      cours = Cour.new(debut: DateTime.parse(params[:date]), 
                        duree: params[:duree], 
                        formation_id: params[:formation_id], 
                        intervenant_id: params[:intervenant_id],
                        salle_id: Salle.first.id,
                        hors_service_statutaire: true)
    end

    if cours
      # Test chaque salle pour voir les disponibilités (cours.valid? == true)
      @salles.each do |s|
        cours.salle = s 
        if cours.valid?
          salles_dispos_ids << s.id
        end 
      end
    end

    #logger.debug salles_dispos_ids

    respond_to do |format|
      format.json do
        render json: Salle.where(id: salles_dispos_ids).to_json
      end
    end
  end

  # Afficher les salles favoris de la formation en JSON
  def favoris_formation
    salles_habituelles_ids = []

    if !params[:formation_id].blank?
      formation = Formation.find(params[:formation_id])
      # Chercher les salles favoris de la formation
      salles_habituelles_ids = formation.cours
        .joins(:salle)
        .where("salles.bloc != 'Z'")
        .select('cours.id')
        .pluck(:salle_id)
        .uniq
        .sort
        .first(5)
    end

    respond_to do |format|
      format.json do
        render json: Salle.where(id: salles_habituelles_ids).pluck(:nom).to_json
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

    def is_user_authorized
      authorize Salle
    end
end
