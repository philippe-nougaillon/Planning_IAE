namespace :tools do

  desc "Import images intervenants"
  task import_imgs: :environment do
    site_url = "https://www.iae-paris.com/sites/default/files/styles/360x265/public/"
    Intervenant.where(status: ['PR', 'PAST', 'MCF'], photo: nil).each do |intervenant|
      image_found = false
      puts intervenant.nom
      if intervenant.nom.include?('_') or intervenant.nom.include?(' ')
        puts 'SKIP'
        puts '* ' * 20 
        next
      end

      2023.downto(2020).each do |year|
        puts year

        result = 12.downto(1).each do |month|
          puts month
          img_url = "#{site_url}#{year}-#{month.to_s.rjust(2, '0')}/#{intervenant.nom.humanize}.png"
          res = Net::HTTP.get_response(URI.parse(img_url))
          if res.code.to_i >= 200 && res.code.to_i < 400
            image_found = true
            puts 'IMAGE TROUVEE'
            intervenant.update(photo: img_url)
            break
          end
        end

        break if image_found
      end
      puts '---' * 20
    end
  end

end