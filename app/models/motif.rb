# noinspection RubyClassMethodNamingConvention
class Motif < ApplicationRecord
  has_many :justificatif 

  def self.catégories
    {
      0 => "inconnue",
      1 => "arrêt maladie",
      2 => "décès d'un proche",
      3 => "enterrement",
      4 => "rendez-vous médical",
      5 => "entretien d'embauche",
      6 => "en entreprise",
      7 => "autre"
    }
  end
end
