class EdusignLog < ApplicationRecord
  belongs_to :user, optional: true

  enum etat: {success: 0, 
              warning: 1, 
              echec: 2, 
              }

  def username
    user&.username || "Serveur"
  end
end
