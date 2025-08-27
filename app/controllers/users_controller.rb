# ENCODING: UTF-8

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :reactivate]
  before_action :is_user_authorized
  
  # GET /users
  # GET /users.json
  def index
    params[:column] ||= session[:column]
    params[:direction] ||= session[:direction]

    @users = User.kept

    unless params[:discarded].blank?
      @users = User.discarded      
    end

    unless params[:search].blank?
      @users = @users.where("LOWER(nom) like :search or LOWER(prénom) like :search or LOWER(email) like :search", {search: "%#{params[:search]}%".downcase})
    end

    unless params[:admin].blank?
      @users = @users.where(admin:true)
    end

    unless params[:reserver].blank?
      @users = @users.where(reserver:true)
    end

    unless params[:role].blank?
      @users = @users.where(role: params[:role])
    end

    if params[:mauvais_email].present?
      mauvais_email_users_ids = []
      User.where(role: ['étudiant', 'intervenant', 'enseignant']).each do |user|
        if user.unlinked?
          mauvais_email_users_ids << user.id
        end
      end
      @users = @users.where(id: mauvais_email_users_ids)
    end

    session[:column] = params[:column]
    session[:direction] = params[:direction]

    @users = @users
                .reorder(Arel.sql("#{sort_column} #{sort_direction}"))
                .paginate(page: params[:page], per_page: 10)
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @audits = @user.audits.reorder(id: :desc).paginate(page:params[:page], per_page:20)
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'Utilisateur créé avec succès.'}
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'Utilisateur modifié avec succès' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.discard
    # à décommenter uniquement lorsqu'il y a :rememberable d'activé, sinon ceux qui essayeront de se connecter avec le compte discarded auront l'erreur 'Stack level too deep'
    # @user.forget_me! if @user.remember_created_at
    respond_to do |format|
      format.html { redirect_to users_path, notice: 'Utilisateur désactivé !' }
      format.json { head :no_content }
    end
  end

  def reactivate
    @user.undiscard
    respond_to do |format|
      format.html { redirect_to user_path, notice: 'Utilisateur réactivé !' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def sortable_columns
      ['users.nom','users.email', 'users.current_sign_in_at', 'users.sign_in_count']
    end

    def sort_column
      sortable_columns.include?(params[:column]) ? params[:column] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :nom, :prénom, :mobile, :admin, :formation_id, :password, :password_confirmation, :reserver, :role)
    end

    def is_user_authorized
      authorize User
    end
end
