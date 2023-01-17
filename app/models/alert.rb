class Alert < ApplicationRecord
  audited

  enum etat: [:danger, :info, :warning, :success]
end
