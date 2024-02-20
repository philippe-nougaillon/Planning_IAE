import { Controller, Application } from "@hotwired/stimulus"
import Notification from 'stimulus-notification'

const application = Application.start()
application.register('notification', Notification)

// Connects to data-controller="notification"
export default class extends Controller {
  connect() {
  }
}
