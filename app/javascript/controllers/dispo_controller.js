import { Controller } from "stimulus"

export default class extends Controller {
    static targets = [ "selector", 'output', 'date', 'intervenant' ]

    initialize() {
        //this.selectorTarget.style.visibility = "hidden";
    }

    connect() {
        console.log("Hello, Stimulus!", this.element)
    }

    click() {
        console.log("Click !")

        // this.outputTarget.textContent =
        //      `Hello, ${this.intervenantTarget.value}!`

        this.outputTarget.textContent =
            `Hello, ${this.dateTarget.value}!`


    }
}

// https://gorails.com/forum/populate-dropdowns-based-on-selection-with-stimulus-js