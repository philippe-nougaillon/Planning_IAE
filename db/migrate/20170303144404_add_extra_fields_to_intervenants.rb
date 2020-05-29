# encoding: UTF-8

class AddExtraFieldsToIntervenants < ActiveRecord::Migration
  def change
  	add_column :intervenants, :titre1, :string
  	add_column :intervenants, :titre2, :string
  	add_column :intervenants, :spécialité, :string
  	add_column :intervenants, :téléphone_fixe, :string
  	add_column :intervenants, :téléphone_mobile, :string
  	add_column :intervenants, :bureau, :string
  end
end
