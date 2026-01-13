class AddSujetReferenceToCour < ActiveRecord::Migration[7.2]
  def change
    add_reference :cours, :sujet, foreign_key: true
    
    Sujet.all.each do |sujet|
      c = Cour.find_by(id: sujet.cour_id)
      c.sujet_id = sujet.id
      c.save
    end
  end
end
