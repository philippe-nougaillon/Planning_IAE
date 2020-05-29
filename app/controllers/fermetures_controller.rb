# encoding: UTF-8

class FermeturesController < ApplicationController
  before_action :set_fermeture, only: [:show, :edit, :update, :destroy]

  # GET /fermetures
  # GET /fermetures.json
  def index
    authorize Fermeture

    params[:paginate] ||= 'pages'

    @fermetures = Fermeture.all

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

    if params[:paginate] == 'pages'
       @fermetures = @fermetures.paginate(page: params[:page], per_page: 20)
    end

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

    if params[:date_fin].present?
      if params[:date_fin] != @fermeture.date
        @start_date = Date.civil(params[:fermeture]["date(1i)"].to_i,
                                 params[:fermeture]["date(2i)"].to_i,
                                 params[:fermeture]["date(3i)"].to_i)

        @end_date = Date.civil(params[:date_fin]["date(1i)"].to_i,
                               params[:date_fin]["date(2i)"].to_i,
                               params[:date_fin]["date(3i)"].to_i)

        # éviter le premier jour de fermeture (@fermeture.save plus loin)
        current_date = @start_date + 1.day
        @ndays = (@end_date - @start_date).to_i

        @ndays.times do
          f = Fermeture.create(date:current_date)
          # logger.debug "[DEBUG] #{f.inspect}"
          current_date = current_date + 1.day
        end

      end
    end

    respond_to do |format|
      if @fermeture.save
        format.html { redirect_to fermetures_url, notice: 'Jour(s) de fermeture ajouté(s)' }
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
        format.html { redirect_to fermetures_url, notice: 'Jour de fermeture modifié' }
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
    @fermeture.destroy
    respond_to do |format|
      format.html { redirect_to fermetures_url, notice: 'Jour de fermeture supprimé' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fermeture
      @fermeture = Fermeture.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fermeture_params
      params.require(:fermeture).permit(:date)
    end
end
