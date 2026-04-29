import { BrokerMessage } from "@medusajs/event-broker"
import { ERPClient } from "../erp-client"
import { ERPCustomer, MedusaCustomerData } from "../types"

export async function syncCustomer(
  msg: BrokerMessage,
  client: ERPClient
): Promise<void> {
  const customer = msg.data as MedusaCustomerData

  const fullName = [customer.first_name, customer.last_name]
    .filter(Boolean)
    .join(" ")
    .trim() || customer.email

  const doc: ERPCustomer = {
    doctype: "Customer",
    customer_name: fullName,
    customer_type: "Individual",
    customer_group: "Individual",
    territory: "Kenya",
    custom_medusa_customer_id: customer.id,
    email_id: customer.email,
    mobile_no: customer.phone,
  }

  await client.upsertByField(
    "Customer",
    "custom_medusa_customer_id",
    customer.id,
    doc as unknown as Record<string, unknown>
  )
}
