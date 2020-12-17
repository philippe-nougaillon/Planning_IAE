class IntervenantMailerPreview < ActionMailer::Preview
    include Roadie::Rails::Automatic

    def notifier_cours
        IntervenantMailer.with(to: "philippe.nougaillon@gmail.com", subject:"[PLANNING] Rappel de vos cours à l'IAE Paris")
                        .notifier_cours("2021-01-01".to_date, "2020-02-01".to_date, 
                                        Intervenant.find(445), 
                                        Cour.last(20) , 
                                        [["la formation....", "email du gestionnaire...."]], 
                                        EnvoiLog.last.id)
    end

end
