class Alert < ApplicationRecord
  audited

  enum etat: [:danger, :info, :warning, :success]

  default_scope { order('updated_at DESC')}

  scope :visibles, -> { where("? BETWEEN alerts.debut AND alerts.fin", Time.now) }

  def visible?
    Alert.visibles.include?(self)
  end
end
