// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"

// Eager load all controllers defined in the import map under controllers/**/*_controller
// import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
// eagerLoadControllersFrom("controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)


// import HelloController from "./hello_controller"
// application.register("hello", HelloController)

// import ActionController from "./action_controller"
// application.register("action", ActionController)

// import CheckboxSelectAllController from "./checkbox_select_all_controller"
// application.register("checkbox-select-all", CheckboxSelectAllController)

// import DispoController from "./dispo_controller"
// application.register("dispo", DispoController)

// import Select2Controller from "./select2_controller"
// application.register("select2", Select2Controller)
