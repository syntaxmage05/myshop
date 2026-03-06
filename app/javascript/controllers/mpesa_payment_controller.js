// app/javascript/controllers/mpesa_payment_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["status", "message", "loading", "success", "failed", "cancelButton"]
  static values = {
    transactionId: String,
    orderId: String
  }

  connect() {
    console.log("M-Pesa payment controller connected")
    this.checkInterval = null
    this.attempts = 0
    this.maxAttempts = 30
    
    this.startPolling()
  }

  disconnect() {
    this.stopPolling()
  }

  startPolling() {
    setTimeout(() => {
      this.showStatus("loading")
      this.checkInterval = setInterval(() => {
        this.checkPaymentStatus()
      }, 3000)
    }, 3000)
  }

  stopPolling() {
    if (this.checkInterval) {
      clearInterval(this.checkInterval)
      this.checkInterval = null
    }
  }

  checkPaymentStatus() {
    this.attempts++
    
    fetch(`/mpesa/status/${this.transactionIdValue}`, {
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === "COMPLETED") {
        this.handleSuccess()
      } else if (data.status === "FAILED") {
        this.handleFailure(data.result_desc || "Payment failed")
      } else if (this.attempts >= this.maxAttempts) {
        this.handleTimeout()
      }
    })
    .catch(error => {
      console.error("Error checking payment status:", error)
      if (this.attempts >= this.maxAttempts) {
        this.handleTimeout()
      }
    })
  }

  handleSuccess() {
    this.stopPolling()
    this.showStatus("success")
    
    setTimeout(() => {
      window.location.href = `/orders/${this.orderIdValue}/thank_you`
    }, 3000)
  }

  handleFailure(message) {
    this.stopPolling()
    this.showStatus("failed", message)
  }

  handleTimeout() {
    this.stopPolling()
    this.showStatus("timeout")
  }

  showStatus(status, message = "") {
    document.getElementById("payment-initial")?.classList.add("d-none")
    this.loadingTarget?.classList.add("d-none")
    this.successTarget?.classList.add("d-none")
    this.failedTarget?.classList.add("d-none")
    this.cancelButtonTarget?.classList.add("d-none")
    
    switch(status) {
      case "loading":
        this.loadingTarget?.classList.remove("d-none")
        break
      case "success":
        this.successTarget?.classList.remove("d-none")
        break
      case "failed":
      case "timeout":
        this.failedTarget?.classList.remove("d-none")
        if (message && this.messageTarget) {
          this.messageTarget.textContent = status === "timeout" 
            ? "Payment timed out. Please check your M-Pesa messages or try again."
            : message
        }
        break
    }
  }
}