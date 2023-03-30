class RebuildPgSearchEtudiants < ActiveRecord::Migration[6.1]
  def change
    PgSearch::Multisearch.rebuild(Etudiant)
  end
end
