class Presence < ApplicationRecord
  belongs_to :cour
  belongs_to :user

  scope :ordered, -> { order(created_at: :desc) }
end
