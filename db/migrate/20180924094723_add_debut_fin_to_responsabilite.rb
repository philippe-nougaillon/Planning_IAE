class AddDebutFinToResponsabilite < ActiveRecord::Migration
  def change
    add_column :responsabilites, :debut, :date
    add_column :responsabilites, :fin, :date
  end
end
