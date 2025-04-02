class Attendance < ApplicationRecord
  belongs_to :etudiant
  belongs_to :cour

  has_one :signatureEmail, dependent: :nullify

  scope :ordered, -> { order(updated_at: :desc) }

  def style
    if self.signatureEmail && !self.état
      "badge-warning"
    elsif self.état && !self.exclu_le
      "badge-success"
    else
      "badge-error"
    end
  end

  def état_text
    if self.signatureEmail && !self.état
      "En attente"
    elsif self.état
      if self.exclu_le
        "Exclu"
      else
        "Présent"
      end
    else
      if self.justificatif_edusign_id
        "Absence justifié"
      else
        "Absent"
      end
    end
  end

  def a_un_retard
    self.retard && self.retard > 0
  end

end
