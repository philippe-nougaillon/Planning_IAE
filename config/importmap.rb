# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "trix", to: "https://ga.jspm.io/npm:trix@2.0.8/dist/trix.esm.min.js"
pin "stimulus-checkbox-select-all", to: "https://ga.jspm.io/npm:stimulus-checkbox-select-all@5.3.0/dist/stimulus-checkbox-select-all.mjs"
pin "@rails/ujs", to: "@rails--ujs.js" # @7.1.3
