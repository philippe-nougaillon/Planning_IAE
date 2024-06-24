class VacationActivite < ApplicationRecord

  has_many :vacation_activite_tarifs

  accepts_nested_attributes_for :vacation_activite_tarifs, allow_destroy:true
end
