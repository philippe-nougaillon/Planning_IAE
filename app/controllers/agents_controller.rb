class AgentsController < ApplicationController
  before_action :set_agent, only: %i[ show edit update destroy ]
  before_action :is_user_authorized

  # GET /agents or /agents.json
  def index
    @agents = Agent.all

    @agents = @agents
                      .reorder("#{sort_column} #{sort_direction}")  
                      .paginate(page: params[:page], per_page: 10)
  end

  # GET /agents/1 or /agents/1.json
  def show
  end

  # GET /agents/new
  def new
    @agent = Agent.new
  end

  # GET /agents/1/edit
  def edit
  end

  # POST /agents or /agents.json
  def create
    @agent = Agent.new(agent_params)

    respond_to do |format|
      if @agent.save
        format.html { redirect_to agents_path, notice: "Agent créé avec succès." }
        format.json { render :show, status: :created, location: @agent }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @agent.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /agents/1 or /agents/1.json
  def update
    respond_to do |format|
      if @agent.update(agent_params)
        format.html { redirect_to agents_path, notice: "Agent modifié avec succès." }
        format.json { render :show, status: :ok, location: @agent }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @agent.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agents/1 or /agents/1.json
  def destroy
    @agent.destroy
    respond_to do |format|
      format.html { redirect_to agents_path, notice: "Agent supprimé avec succès." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_agent
      @agent = Agent.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def agent_params
      params.require(:agent).permit(:nom, :prénom, :catégorie)
    end

    def sortable_columns
      ['agents.nom','agents.prénom','agents.catégorie', 'agents.created_at']
    end

    def sort_column
        sortable_columns.include?(params[:column]) ? params[:column] : "nom"
    end

    def sort_direction
        %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def is_user_authorized
      authorize Agent
    end
end
