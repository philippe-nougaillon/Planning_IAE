import $ from 'jquery'
import 'select2/dist/css/select2.css'
import 'select2'

$(document).on('turbolinks:load', function(){ 
  $('.select2').select2()
})