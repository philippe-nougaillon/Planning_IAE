class VacationActivite < ApplicationRecord
  audited

  has_many :vacations
  has_many :vacation_activite_tarifs, dependent: :destroy
  accepts_nested_attributes_for :vacation_activite_tarifs, allow_destroy:true

  scope :ordered, -> {order(:nature, :nom)}

  def self.for_select
    grouped_activites = {}
    VacationActivite.all.pluck(:nature).uniq.sort.each do |nature|
      grouped_activites[nature] = VacationActivite.where(nature: nature).pluck(:nom, :id).sort
    end
    grouped_activites
  end
end
