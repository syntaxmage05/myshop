// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import MpesaPaymentController from "./mpesa_payment_controller"
eagerLoadControllersFrom("controllers", application)

application.register("mpesa-payment", MpesaPaymentController)
