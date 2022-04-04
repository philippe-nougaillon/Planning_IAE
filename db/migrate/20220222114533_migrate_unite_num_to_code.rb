class MigrateUniteNumToCode < ActiveRecord::Migration[6.1]
  def change
    Unite.where.not(num: nil).each do |u| 
      u.code = u.num.strip.gsub('UE','').to_i
      u.save(validate: false)

      puts u.num.to_s + ' => ' + u.code.to_s + ' ==> ' + u.num.strip.gsub('UE','').to_i.to_s
      puts u.errors.full_messages
    end
  end
end
