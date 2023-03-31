class IntervenantMailerPreview < ActionMailer::Preview
    include Roadie::Rails::Automatic

    def notifier_cours
        IntervenantMailer.with(to: "philippe.nougaillon@gmail.com", subject:"[PLANNING] Rappel de vos cours à l'IAE Paris")
                         .notifier_cours("2022-01-01".to_date, 
                                        "2022-02-01".to_date, 
                                        Intervenant.first, 
                                        Cour.last(20) , 
                                        [["la formation....", "courriel@lkjlkjl.fr"]], 
                                        EnvoiLog.first.id)
    end

    def welcome_intervenant
        IntervenantMailer.with(user: User.find(1), password: SecureRandom.hex(10)).welcome_intervenant
    end

end
