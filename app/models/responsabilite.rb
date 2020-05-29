class Responsabilite < ApplicationRecord

  audited

  belongs_to :intervenant
  belongs_to :formation
end
