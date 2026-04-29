import { AmqpPublisher, AmqpSubscriber, BrokerMessage } from "@medusajs/event-broker"
import { ERPClient } from "./erp-client"
import { syncOrderCanceled, syncOrderCompleted, syncOrderPlaced } from "./handlers/sync-order"
import { syncCustomer } from "./handlers/sync-customer"
import { syncPaymentCaptured } from "./handlers/sync-payment"
import { startWebhookServer } from "./webhook-server"

async function main() {
  const rabbitmqUrl = process.env.RABBITMQ_URL
  if (!rabbitmqUrl) throw new Error("RABBITMQ_URL is required")

  const erpConfig = {
    url: process.env.ERPNEXT_URL ?? "http://localhost:8080",
    site: process.env.ERPNEXT_SITE ?? "erp.localhost",
    apiKey: process.env.ERPNEXT_API_KEY ?? "",
    apiSecret: process.env.ERPNEXT_API_SECRET ?? "",
  }

  const webhookPort = parseInt(process.env.ERP_WEBHOOK_PORT ?? "4001", 10)

  const erp = new ERPClient(erpConfig)

  // ── Outbound: RabbitMQ → ERPNext ──────────────────────────────────────────
  const subscriber = new AmqpSubscriber({ url: rabbitmqUrl })
  await subscriber.connect()
  console.log("erp-connector: connected to RabbitMQ")

  const dispatch = async (msg: BrokerMessage): Promise<void> => {
    console.log("erp-connector: handling", msg.event)
    try {
      switch (msg.event) {
        case "order.placed":
          await syncOrderPlaced(msg, erp)
          break
        case "order.completed":
        case "order.archived":
          await syncOrderCompleted(msg, erp)
          break
        case "order.canceled":
          await syncOrderCanceled(msg, erp)
          break
        case "customer.created":
        case "customer.updated":
          await syncCustomer(msg, erp)
          break
        case "payment.captured":
          await syncPaymentCaptured(msg, erp)
          break
        default:
          // unhandled event — no-op
      }
    } catch (err) {
      console.error(`erp-connector: error handling ${msg.event}:`, err)
    }
  }

  await subscriber.subscribe("order.*", dispatch)
  await subscriber.subscribe("customer.*", dispatch)
  await subscriber.subscribe("payment.*", dispatch)
  console.log("erp-connector: subscribed to order.*, customer.*, payment.*")

  // ── Inbound: ERPNext webhooks → RabbitMQ ──────────────────────────────────
  const publisher = new AmqpPublisher({ url: rabbitmqUrl })
  await publisher.connect()

  startWebhookServer(publisher, webhookPort)

  // Graceful shutdown
  const shutdown = async () => {
    console.log("erp-connector: shutting down...")
    await subscriber.close()
    await publisher.close()
    process.exit(0)
  }

  process.on("SIGTERM", shutdown)
  process.on("SIGINT", shutdown)
}

main().catch((err) => {
  console.error("erp-connector: fatal error:", err)
  process.exit(1)
})
