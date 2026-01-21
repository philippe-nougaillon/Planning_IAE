# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# EnvoiLog.create(date_prochain: Date.parse('2021-09-24')) unless EnvoiLog.any?

Ouverture.create([
  { bloc: "P", jour: "lundi", début: "2000-01-01 08:00:00.000000000 +0000", fin: "2000-01-01 22:00:00.000000000 +0000"},
  { bloc: "P", jour: "mardi", début: "2000-01-01 08:00:00.000000000 +0000", fin: "2000-01-01 22:00:00.000000000 +0000"},
  { bloc: "P", jour: "mercredi", début: "2000-01-01 08:00:00.000000000 +0000", fin: "2000-01-01 22:00:00.000000000 +0000"},
  { bloc: "P", jour: "jeudi", début: "2000-01-01 08:00:00.000000000 +0000", fin: "2000-01-01 22:00:00.000000000 +0000"},
  { bloc: "P", jour: "vendredi", début: "2000-01-01 08:00:00.000000000 +0000", fin: "2000-01-01 22:00:00.000000000 +0000"},
  { bloc: "P", jour: "samedi", début: "2000-01-01 08:00:00.000000000 +0000", fin: "2000-01-01 22:00:00.000000000 +0000"},
])

amphithéâtre = Salle.create(nom: "Amphithéâtre", bloc: "P", places: 90)
rdj_1 = Salle.create(nom: "RDJ.1", bloc: "P", places: 55)
rdj_2 = Salle.create(nom: "RDJ.2", bloc: "P", places: 16)
auditorium = Salle.create(nom: "Auditorium", bloc: "P", places: 52)
rdc_1 = Salle.create(nom: "RDC.1", bloc: "P", places: 48)
salle_1_1 = Salle.create(nom: "1.1", bloc: "P", places: 31)
salle_1_2 = Salle.create(nom: "1.2", bloc: "P", places: 55)
salle_1_3 = Salle.create(nom: "1.3", bloc: "P", places: 50)
salle_2_1 = Salle.create(nom: "2.1", bloc: "P", places: 38)
salle_2_2 = Salle.create(nom: "2.2", bloc: "P", places: 38)
salle_2_3 = Salle.create(nom: "2.3", bloc: "P", places: 50)
salle_2_4 = Salle.create(nom: "2.4", bloc: "P", places: 40)
salle_2_5 = Salle.create(nom: "2.5", bloc: "P", places: 27)
salle_2_6 = Salle.create(nom: "2.6", bloc: "P", places: 30)
salle_3_6 = Salle.create(nom: "3.6", bloc: "P", places: 25)
salle_3_7 = Salle.create(nom: "3.7", bloc: "P", places: 25)
# salle_3_a = Salle.create(nom: "3.A", bloc: "P", places: 5, privée: true)
# salle_3_b = Salle.create(nom: "3.B", bloc: "P", places: 5, privée: true)
# salle_3_c = Salle.create(nom: "3.C", bloc: "P", places: 4, privée: true)
# salle_300 = Salle.create(nom: "300", bloc: "P", places: 2, privée: true)
# salle_301 = Salle.create(nom: "301", bloc: "P", places: 2, privée: true)
# salle_302 = Salle.create(nom: "302", bloc: "P", places: 2, privée: true)
# salle_303 = Salle.create(nom: "303", bloc: "P", places: 2, privée: true)
# salle_304 = Salle.create(nom: "304", bloc: "P", places: 2, privée: true)
# salle_305 = Salle.create(nom: "305", bloc: "P", places: 2, privée: true)
# salle_4_a = Salle.create(nom: "4.A", bloc: "P", places: 7, privée: true)
# salle_4_b = Salle.create(nom: "4.B", bloc: "P", places: 7, privée: true)
# salle_5_a = Salle.create(nom: "5.A", bloc: "P", places: 8, privée: true)
# salle_6_a = Salle.create(nom: "6.A", bloc: "P", places: 6, privée: true)
# salle_6_b = Salle.create(nom: "6.B", bloc: "P", places: 12, privée: true)


date_limite = Date.new(2026,4,1)
cours = Cour.where("DATE(debut) > ?", date_limite)
cours.where(salle_id: Salle.find_by(nom: "B1").id).update_all(salle_id: amphithéâtre.id)
cours.where(salle_id: Salle.find_by(nom: "D5").id).update_all(salle_id: rdj_1.id)
cours.where(salle_id: Salle.find_by(nom: "B2").id).update_all(salle_id: auditorium.id)
cours.where(salle_id: Salle.find_by(nom: "D4").id).update_all(salle_id: rdc_1.id)
cours.where(salle_id: Salle.find_by(nom: "A2").id).update_all(salle_id: salle_1_1.id)
cours.where(salle_id: Salle.find_by(nom: "D6").id).update_all(salle_id: salle_1_2.id)
cours.where(salle_id: Salle.find_by(nom: "D1").id).update_all(salle_id: salle_1_3.id)
cours.where(salle_id: Salle.find_by(nom: "A4").id).update_all(salle_id: salle_2_1.id)
cours.where(salle_id: Salle.find_by(nom: "A5").id).update_all(salle_id: salle_2_2.id)
cours.where(salle_id: Salle.find_by(nom: "A1").id).update_all(salle_id: salle_2_3.id)
cours.where(salle_id: Salle.find_by(nom: "D2").id).update_all(salle_id: salle_2_4.id)
cours.where(salle_id: Salle.find_by(nom: "D3").id).update_all(salle_id: salle_2_5.id)
cours.where(salle_id: Salle.find_by(nom: "A3").id).update_all(salle_id: salle_2_6.id)
cours.where(salle_id: Salle.find_by(nom: "B3").id).update_all(salle_id: salle_3_6.id)