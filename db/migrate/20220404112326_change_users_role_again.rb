class ChangeUsersRoleAgain < ActiveRecord::Migration[6.1]
  def change
    # Les gestionnaires
    User.where(admin: true, reserver: true).each do |user|
      user.role = :gestionnaire
      user.save
    end

    # les autres
    User.where(admin: false, reserver: true).each do |user|
      user.role = :accueil
      user.save
    end

  end
end
