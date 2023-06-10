import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="poll-result"
export default class extends Controller {
  connect() {
    console.log("connected!");
  }
  toggle() {
    if (document.querySelector("#responses").style["display"] === "block") {
        document.querySelector("#responses").style["display"] = "none";
    } else {
        document.querySelector("#responses").style["display"] = "block";
    }
  }
}
