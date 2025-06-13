class EdusignLog < ApplicationRecord
  belongs_to :user, optional: true

  def username
    user&.username || "Serveur"
  end
end
