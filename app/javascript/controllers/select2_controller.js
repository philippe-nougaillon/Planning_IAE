import { Controller } from "@hotwired/stimulus"
import $ from 'jquery';
import 'select2/dist/css/select2.min.css'
import Select2 from "select2"

export default class extends Controller {
  connect() {
    Select2()
    $('.select2').select2();
    $('.select2-w100').select2({width: "100%"});
  }
}