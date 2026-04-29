import { AmqpSubscriber } from "@medusajs/event-broker"
import { IEventBusModuleService } from "@medusajs/framework/types"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"
import { MedusaContainer } from "@medusajs/framework/types"

export default async function amqpInboundLoader(
  container: MedusaContainer
): Promise<void> {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)

  const url = process.env.RABBITMQ_URL
  if (!url) {
    logger.warn(
      "amqp-inbound: RABBITMQ_URL not set — inbound RabbitMQ listener disabled"
    )
    return
  }

  const rawPatterns = process.env.RABBITMQ_INBOUND_PATTERNS ?? "delivery.*,payment.*"
  const patterns = rawPatterns
    .split(",")
    .map((p) => p.trim())
    .filter(Boolean)

  const eventBus: IEventBusModuleService = container.resolve(
    Modules.EVENT_BUS
  )

  const subscriber = new AmqpSubscriber({ url })
  await subscriber.connect()

  for (const pattern of patterns) {
    await subscriber.subscribe(pattern, async (msg) => {
      try {
        await eventBus.emit({ eventName: msg.event, data: msg.data })
      } catch (err) {
        logger.error(
          "amqp-inbound: failed to emit " + msg.event + " into Medusa: " + err
        )
      }
    })
    logger.info("amqp-inbound: subscribed to pattern " + pattern)
  }

  logger.info(
    "amqp-inbound: RabbitMQ inbound listener started for " +
      patterns.join(", ")
  )
}
