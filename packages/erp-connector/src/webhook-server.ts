import { AmqpPublisher } from "@medusajs/event-broker"
import express, { Request, Response } from "express"
import { ERPWebhookPayload } from "./types"

/**
 * Tiny Express server that receives ERPNext webhooks and publishes them
 * to RabbitMQ so Medusa's amqp-inbound loader can pick them up.
 *
 * Configure webhooks in ERPNext:
 *   Settings → Webhook → New Webhook
 *   URL: http://<connector-host>:4001/erp-webhook
 *   Request Method: POST
 *   Trigger: e.g. "Bin" (stock ledger), "Item Price"
 */
export function startWebhookServer(
  publisher: AmqpPublisher,
  port: number
): void {
  const app = express()
  app.use(express.json())

  app.get("/health", (_req: Request, res: Response) => {
    res.json({ status: "ok" })
  })

  app.post("/erp-webhook", async (req: Request, res: Response) => {
    const payload = req.body as ERPWebhookPayload

    if (!payload?.doctype) {
      res.status(400).json({ error: "missing doctype" })
      return
    }

    // Map ERPNext doctype events to routing keys Medusa understands
    const routingKey = doctypeToRoutingKey(payload.doctype, payload.data)
    if (!routingKey) {
      res.status(200).json({ skipped: true })
      return
    }

    await publisher.publish(routingKey, payload.data)
    res.json({ published: routingKey })
  })

  app.listen(port, () => {
    console.log(`erp-connector webhook server listening on port ${port}`)
  })
}

function doctypeToRoutingKey(
  doctype: string,
  data: Record<string, unknown>
): string | null {
  switch (doctype) {
    // Stock / inventory updates from ERPNext Bin doctype
    case "Bin":
      return "inventory.updated"

    // Item price changes
    case "Item Price":
      return "price.updated"

    // Delivery note submitted → delivery confirmed
    case "Delivery Note":
      return data["docstatus"] === 1 ? "delivery.updated" : null

    // Purchase receipt (restock)
    case "Purchase Receipt":
      return data["docstatus"] === 1 ? "stock.received" : null

    default:
      return null
  }
}
