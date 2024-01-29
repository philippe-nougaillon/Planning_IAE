import { Controller, Application } from "@hotwired/stimulus"
import NestedForm from 'stimulus-rails-nested-form'

const application = Application.start()
application.register('nested-form', NestedForm)

// Connects to data-controller="nested-form"
export default class extends Controller {
  connect() {
    console.log("Hello, Stimulus nested_form!", this.element)
  }
}
