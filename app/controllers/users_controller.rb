# ENCODING: UTF-8

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :reactivate]
  before_action :is_user_authorized
  skip_before_action :authenticate_user!, only: [:send_otp]

  # GET /users
  # GET /users.json
  def index
    params[:column_user] ||= session[:column_user]
    params[:direction_user] ||= session[:direction_user]

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

    session[:column_user] = params[:column_user]
    session[:direction_user] = params[:direction_user]

    @users = @users
                .reorder(Arel.sql("#{sort_column} #{sort_direction}"))
                .paginate(page: params[:page], per_page: 10)
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if current_user && !current_user.étudiant?
      @audits = @user.audits.reorder(id: :desc).paginate(page:params[:page], per_page: 10)
    end
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

  def disable_otp
    current_user.otp_required_for_login = false
    current_user.save!
    redirect_to user_path(current_user), notice: "Double authentification désactivée avec succès !"
  end

  def enable_otp
    # Si code de vérification est correct, activer 2FA
    # Sinon redemander le code
    if current_user.validate_and_consume_otp!(params[:otp_attempt])
      current_user.otp_required_for_login = true
      current_user.save!
      redirect_to user_path(current_user), notice: "Double authentification activée avec succès !"
    else
      redirect_to enable_otp_users_path(current_user), alert: "Code de vérification incorrect, veuillez réessayer !"
    end
    
  end

  def qrcode_otp
    current_user.otp_secret = User.generate_otp_secret
    current_user.save!
  end

  def mail_otp
    current_user.otp_secret = User.generate_otp_secret
    current_user.save!

    # Envoie le otp par mail
    UserMailer.mail_otp(current_user).deliver_now
  end

  def send_otp
    if (user = User.find_by(email: params[:email])) && user.valid_password?(params[:password])
      if user.otp_required_for_login
        UserMailer.mail_otp(user).deliver_now
        render json: { otp_required: true }
      else
        render json: { otp_required: false }
      end
      # Vérifier si otp activé
    else
      render json: { error: "Email ou mot de passe incorrect."}
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
      sortable_columns.include?(params[:column_user]) ? params[:column_user] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction_user]) ? params[:direction_user] : "asc"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :nom, :prénom, :mobile, :admin, :formation_id, :password, :password_confirmation, :reserver, :role)
    end

    def is_user_authorized
      authorize @user ? @user : User
    end
end
