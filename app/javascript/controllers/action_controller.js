import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ 'source', 'selector' ]

    initialize() {
        //this.selectorTarget.style.visibility = 'hidden';
        this.selectorTarget.style.display = 'none';
    }

    connect() {
        //console.log("Hello, Stimulus!", this.element)
    }
    click() {
        var check_boxes = this.sourceTargets;
        var enabled = check_boxes.filter(myFunction);
        
        function myFunction(value, index, array) {
          return value.checked;
        } 
 
        //console.log(`Clicks = ${enabled.length}`)
        
        if (enabled.length == 0 ) {
            //this.selectorTarget.style.visibility = 'hidden';
            this.selectorTarget.style.display = 'none';
        } else {
            //this.selectorTarget.style.visibility = 'visible';
            this.selectorTarget.style.display = 'block';
        }
    }
}
