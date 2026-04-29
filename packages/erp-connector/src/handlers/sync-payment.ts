import { BrokerMessage } from "@medusajs/event-broker"
import { ERPClient } from "../erp-client"
import { ERPPaymentEntry, MedusaPaymentData } from "../types"

export async function syncPaymentCaptured(
  msg: BrokerMessage,
  client: ERPClient
): Promise<void> {
  const payment = msg.data as MedusaPaymentData

  // Resolve the ERPNext customer name from the order if available
  let partyName = "Guest"
  if (payment.order_id) {
    const salesOrder = await client.findByField(
      "Sales Order",
      "custom_medusa_order_id",
      payment.order_id
    )
    if (salesOrder) {
      partyName = salesOrder["customer"] as string
    }
  }

  const doc: ERPPaymentEntry = {
    doctype: "Payment Entry",
    payment_type: "Receive",
    party_type: "Customer",
    party: partyName,
    paid_amount: (payment.amount ?? 0) / 100,
    received_amount: (payment.amount ?? 0) / 100,
    paid_from: "Debtors - F",
    paid_to: "Cash - F",
    reference_no: payment.order_id ?? payment.id,
    reference_date: new Date().toISOString().split("T")[0],
    custom_medusa_payment_id: payment.id,
  }

  await client.create(doc)
}
