# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "stimulus", to: "https://ga.jspm.io/npm:stimulus@3.2.2/dist/stimulus.js"
pin "stimulus-check-all", to: "https://ga.jspm.io/npm:stimulus-check-all@0.6.0/src/index.js"
pin "@github/check-all", to: "https://ga.jspm.io/npm:@github/check-all@0.4.0/dist/index.js"
pin "trix", to: "https://ga.jspm.io/npm:trix@2.0.8/dist/trix.esm.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
