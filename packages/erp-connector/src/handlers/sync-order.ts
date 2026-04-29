import { BrokerMessage } from "@medusajs/event-broker"
import { ERPClient } from "../erp-client"
import { MedusaOrderData } from "../types"

function toDate(ts: string | undefined): string {
  return (ts ? new Date(ts) : new Date()).toISOString().split("T")[0]
}

function deliveryDate(): string {
  const d = new Date()
  d.setDate(d.getDate() + 3)
  return d.toISOString().split("T")[0]
}

export async function syncOrderPlaced(
  msg: BrokerMessage,
  client: ERPClient
): Promise<void> {
  const order = msg.data as MedusaOrderData

  // Ensure customer exists first
  const customerName = order.email

  const doc = {
    doctype: "Sales Order" as const,
    customer: customerName,
    transaction_date: toDate(msg.timestamp),
    delivery_date: deliveryDate(),
    currency: (order.currency_code ?? "KES").toUpperCase(),
    order_type: "Sales" as const,
    custom_medusa_order_id: order.id,
    items: (order.items ?? []).map((item) => ({
      item_code: item.variant_id ?? item.product_id ?? item.title,
      item_name: item.title,
      qty: item.quantity,
      rate: (item.unit_price ?? 0) / 100,
      uom: "Nos",
      delivery_date: deliveryDate(),
    })),
  }

  await client.create(doc)
}

export async function syncOrderCompleted(
  msg: BrokerMessage,
  client: ERPClient
): Promise<void> {
  const { id } = msg.data as { id: string }
  const existing = await client.findByField("Sales Order", "custom_medusa_order_id", id)
  if (!existing) return

  await client.submit("Sales Order", existing["name"] as string)
}

export async function syncOrderCanceled(
  msg: BrokerMessage,
  client: ERPClient
): Promise<void> {
  const { id } = msg.data as { id: string }
  const existing = await client.findByField("Sales Order", "custom_medusa_order_id", id)
  if (!existing) return

  await client.cancel("Sales Order", existing["name"] as string)
}
