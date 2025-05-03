// assets/js/app.js
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import html2pdf from 'html2pdf.js'

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// Define our custom hooks
let Hooks = {}

// Hook for copying rendered markdown to clipboard
Hooks.CopyToClipboard = {
  mounted() {
    this.el.addEventListener("click", () => {
      // Get the HTML content from the rendered markdown div
      const markdownOutput = document.getElementById("markdown-output")
      
      // Copy the HTML content to clipboard
      navigator.clipboard.writeText(markdownOutput.innerHTML)
        .then(() => {
          // Trigger a flash message on success
          this.pushEvent("copied_to_clipboard")
          
          // Show temporary success message
          // const flashMessage = document.createElement("span")
          // flashMessage.textContent = "Copied!"
          // flashMessage.className = "text-sm text-green-600 ml-2"
          // this.el.appendChild(flashMessage)
          
          // Remove the message after 2 seconds
          setTimeout(() => {
            flashMessage.remove()
          }, 2000)
        })
        .catch(err => {
          console.error("Could not copy text: ", err)
        })
    })
  }
}

// Hook for exporting rendered markdown to PDF
Hooks.ExportToPDF = {
  mounted() {
    this.el.addEventListener("click", () => {
      const markdownOutput = document.getElementById("markdown-output")
      
      // Configure HTML2PDF options
      const opt = {
        margin: 10,
        filename: 'markdown-export.pdf',
        image: { type: 'jpeg', quality: 0.98 },
        html2canvas: { scale: 2 },
        jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
      }
      
      // Generate and download PDF
      html2pdf().set(opt).from(markdownOutput).save()
    })
  }
}

let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket