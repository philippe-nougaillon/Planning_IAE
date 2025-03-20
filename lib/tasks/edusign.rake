namespace :edusign do
  task justificatifs: :environment do

    def get_response(url)
      request = Net::HTTP::Get.new(url)
      request["accept"] = 'application/json'
      request["content-type"] = 'application/json'
      request["authorization"] = "Bearer #{ENV['EDUSIGN_API_KEY']}"

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      response = JSON.parse(http.request(request).read_body)
    end
    
    def get_reason_by_id(motifs, motif_id)
      motifs.each do |motif|
        if motif["ID"] == motif_id
          return motif["NAME"] 
        end
      end
    end

    def modification_justificatif(j_object, j_json, motifs)
      j_object.nom = get_reason_by_id(motifs, j_json["TYPE"])
      j_object.commentaires = j_json["COMMENT"]
      j_object.etudiant_id = Etudiant.find_by(edusign_id: j_json["STUDENT_ID"]).id
      j_object.file_url = j_json["FILE_URL"]
      j_object.edusign_created_at = j_json["DATE_CREATION"]
      j_object.accepete_le = j_json["REQUEST_DATE"]
      j_object.debut = j_json["START"]
      j_object.fin = j_json["END"]
      j_object.save
    end

    url = URI("https://ext.edusign.fr/v1/justified-absence?page=0")
    
    response = get_response(url)
        
    if response["status"] == 'error'
      puts response["message"]
      return
    end

    justificatifs = response["result"]

    url = URI("https://ext.edusign.fr/v1/justified-absence/absence-reason")

    response = get_response(url)
        
    if response["status"] == 'error'
      puts response["message"]
    end

    motifs = response["result"]

    justificatifs.each do |justificatif|

      if Justificatif.where(edusign_id: justificatif["ID"]).blank?
        j = Justificatif.new
        j.edusign_id = justificatif["ID"]
        modification_justificatif(j, justificatif, motifs)
      else
        j = Justificatif.find_by(edusign_id: justificatif["ID"])
        modification_justificatif(j, justificatif, motifs)
      end

    end
  end
end