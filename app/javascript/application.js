// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

Turbo.setFormMode("optin") // No turbo forms unless you insist. Use data-turbo="true" to enable turbo on individual forms.