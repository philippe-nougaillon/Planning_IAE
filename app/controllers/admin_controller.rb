class AdminController < ApplicationController
  before_action :is_user_authorized
  def create_new_user
    @user = User.new
  end

  def create_new_user_do
    @user = User.new(params.require(:user).permit(:nom, :prénom, :email, :mobile, :role))
    user_password = @user.password = User.generate_random_password

    respond_to do |format|
      if @user.save
        key_len = ActiveSupport::MessageEncryptor.key_len
        secret_key = Rails.application.key_generator.generate_key('import_password', key_len)
        encryptor = ActiveSupport::MessageEncryptor.new(secret_key)
        encrypted_password = encryptor.encrypt_and_sign(user_password)
        SendNewAccountPasswordJob.perform_later(@user, current_user.id, encrypted_password)
        format.html { redirect_to user_url(@user), notice: "Utilisateur créé avec succès. Un mail contenant son mot de passe vient de lui être envoyé" }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :create_new_user, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def is_user_authorized
    authorize :admin
  end
end
