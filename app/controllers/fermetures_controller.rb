# encoding: UTF-8

class FermeturesController < ApplicationController
  before_action :set_fermeture, only: [:show, :edit, :update, :destroy]
  before_action :is_user_authorized

  # GET /fermetures
  # GET /fermetures.json
  def index

    params[:futur] ||= 'oui'
    params[:paginate] ||= 'pages'
    params[:column] ||= session[:column]
    params[:direction_fermetures] ||= session[:direction_fermetures]

    @fermetures = Fermeture.all
    @noms_périodes = Fermeture.where.not(nom: nil).pluck(:nom).uniq.sort

    unless params[:nom].blank?
      @fermetures = @fermetures.where(nom: params[:nom])
    end

    if !params[:date_debut].blank? and params[:date_fin].blank? 
      @date = params[:date_debut].to_date
      @fermetures = @fermetures.where("fermetures.date = DATE(?)", @date)
    else
      unless params[:date_debut].blank? and params[:date_fin].blank? 
        @date = params[:date_debut].to_date
        @date_fin = params[:date_fin].to_date
        @fermetures = @fermetures.where("fermetures.date BETWEEN DATE(?) AND DATE(?)", @date, @date_fin)
      end
    end

    @fermetures = @fermetures.order("#{sort_column} #{sort_direction}")

    if params[:futur] == 'oui'
      @fermetures = @fermetures.where('date >= ?', Date.today)
    end

    if params[:paginate] == 'pages'
       @fermetures = @fermetures.paginate(page: params[:page], per_page: 20)
    end

    session[:column] = params[:column]
    session[:direction_fermetures] = params[:direction_fermetures]

  end

  # GET /fermetures/1
  # GET /fermetures/1.json
  def show
  end

  # GET /fermetures/new
  def new
    @fermeture = Fermeture.new
  end

  # GET /fermetures/1/edit
  def edit
  end

  # POST /fermetures
  # POST /fermetures.json
  def create
    @fermeture = Fermeture.new(fermeture_params)
    
    respond_to do |format|
      if @fermeture.save

        # Créer chaque jour de la période
        if params[:date_fin].present?
          if params[:date_fin] != @fermeture.date
            start_date = Date.parse(params[:fermeture]["date"])
            end_date   = Date.parse(params[:date_fin])
            nom = params[:fermeture][:nom]
    
            # éviter le premier jour de fermeture (le @fermeture.save plus haut a déjà créé le jour)
            current_date = start_date + 1.day
            ndays = (end_date - start_date).to_i
    
            ndays.times do
              f = Fermeture.create(date: current_date, nom: nom)
              current_date = current_date + 1.day
            end
          end
        end
    
        format.html { redirect_to fermetures_path, notice: 'Jour(s) de fermeture ajouté(s)' }
        format.json { render :show, status: :created, location: @fermeture }
      else
        format.html { render :new }
        format.json { render json: @fermeture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fermetures/1
  # PATCH/PUT /fermetures/1.json
  def update
    respond_to do |format|
      if @fermeture.update(fermeture_params)
        format.html { redirect_to fermetures_path, notice: 'Jour de fermeture modifié' }
        format.json { render :show, status: :ok, location: @fermeture }
      else
        format.html { render :edit }
        format.json { render json: @fermeture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fermetures/1
  # DELETE /fermetures/1.json
  def destroy
    date_debut = @fermeture.date
    @fermeture.destroy
    respond_to do |format|
      format.html { redirect_to fermetures_path, notice: 'Jour de fermeture supprimé' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fermeture
      @fermeture = Fermeture.find(params[:id])
    end

    def sortable_columns
      ['fermetures.date', 'fermetures.nom', 'fermetures.updated_at']
    end

    def sort_column
      sortable_columns.include?(params[:column]) ? params[:column] : "date, updated_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction_fermetures]) ? params[:direction_fermetures] : "asc"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fermeture_params
      params.require(:fermeture).permit(:date, :nom)
    end

    def is_user_authorized
      authorize Fermeture
    end
end
