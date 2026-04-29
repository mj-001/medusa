export interface ERPNextConfig {
  url: string
  site: string
  apiKey: string
  apiSecret: string
}

// ── Medusa event payloads (subset we care about) ────────────────────────────

export interface MedusaOrderData {
  id: string
  display_id: number
  status: string
  email: string
  currency_code: string
  customer_id?: string
  total: number
  subtotal: number
  shipping_total: number
  items: Array<{
    id: string
    title: string
    quantity: number
    unit_price: number
    variant_id?: string
    product_id?: string
  }>
  shipping_address?: {
    first_name?: string
    last_name?: string
    address_1?: string
    city?: string
    phone?: string
  }
}

export interface MedusaCustomerData {
  id: string
  email: string
  first_name?: string
  last_name?: string
  phone?: string
}

export interface MedusaPaymentData {
  id: string
  amount: number
  currency_code: string
  order_id?: string
  customer_id?: string
}

export interface MedusaProductData {
  id: string
  title: string
  description?: string
  variants?: Array<{
    id: string
    title: string
    sku?: string
    prices?: Array<{ amount: number; currency_code: string }>
    manage_inventory?: boolean
    inventory_quantity?: number
  }>
}

// ── ERPNext doctype payloads ─────────────────────────────────────────────────

export interface ERPSalesOrder {
  doctype: "Sales Order"
  customer: string
  transaction_date: string
  delivery_date: string
  currency: string
  order_type: "Sales"
  custom_medusa_order_id: string
  items: Array<{
    item_code: string
    item_name: string
    qty: number
    rate: number
    uom: string
    delivery_date: string
  }>
}

export interface ERPCustomer {
  doctype: "Customer"
  customer_name: string
  customer_type: "Individual" | "Company"
  customer_group: string
  territory: string
  custom_medusa_customer_id: string
  email_id?: string
  mobile_no?: string
}

export interface ERPPaymentEntry {
  doctype: "Payment Entry"
  payment_type: "Receive"
  party_type: "Customer"
  party: string
  paid_amount: number
  received_amount: number
  paid_from: string
  paid_to: string
  reference_no: string
  reference_date: string
  custom_medusa_payment_id: string
}

export interface ERPItem {
  doctype: "Item"
  item_code: string
  item_name: string
  item_group: string
  stock_uom: string
  description?: string
  custom_medusa_product_id: string
  custom_medusa_variant_id?: string
  is_sales_item: number
  is_stock_item: number
}

// ── Inbound webhook from ERPNext ─────────────────────────────────────────────

export interface ERPWebhookPayload {
  doctype: string
  docname: string
  data: Record<string, unknown>
}
