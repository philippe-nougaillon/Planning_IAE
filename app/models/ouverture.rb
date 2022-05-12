class Ouverture < ApplicationRecord
  audited

  enum jour: {dimanche: 0, lundi: 1, mardi: 2, mercredi: 3, jeudi: 4, vendredi: 5, samedi: 6}

  default_scope {order(:bloc, :jour)}

  validates :jour, uniqueness: { scope: :bloc }

  def horaires
    "#{ self.début.strftime("%Hh%M") }-#{ self.fin.strftime("%Hh%M") }"
  end
end
