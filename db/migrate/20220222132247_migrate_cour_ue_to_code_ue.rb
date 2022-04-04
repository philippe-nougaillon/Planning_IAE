class MigrateCourUeToCodeUe < ActiveRecord::Migration[6.1]
  def change
    Cour.where("ue like '%UE%'").each do | c |
      c.code_ue = c.ue.strip.gsub('UE','').to_i
      c.save(validate: false)
    end
  end
end
