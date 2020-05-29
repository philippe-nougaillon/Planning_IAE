# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $('#check_all_trigger').change -> 
    console.log("Check_all_trigger changed to: ", @.checked)
    if @.checked 
    then $(".check_all").each -> this.checked = true     
    else $(".check_all").each -> this.checked = null    