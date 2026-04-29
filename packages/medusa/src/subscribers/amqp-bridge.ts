import { AmqpPublisher } from "@medusajs/event-broker"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { SubscriberArgs, SubscriberConfig } from "../types/subscribers"

let publisher: AmqpPublisher | null = null

async function getPublisher(): Promise<AmqpPublisher | null> {
  const url = process.env.RABBITMQ_URL
  if (!url) return null

  if (!publisher) {
    publisher = new AmqpPublisher({ url })
    await publisher.connect()
  }
  return publisher
}

export default async function amqpBridgeHandler({
  event,
  container,
}: SubscriberArgs<unknown>) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)
  const pub = await getPublisher()

  if (!pub) {
    logger.warn(
      "amqp-bridge: RABBITMQ_URL not set — skipping publish for " + event.name
    )
    return
  }

  try {
    await pub.publish(event.name, event.data)
  } catch (err) {
    logger.error("amqp-bridge: failed to publish " + event.name + ": " + err)
  }
}

export const config: SubscriberConfig = {
  event: [
    "auth.password_reset",
    "cart.created",
    "cart.customer_transferred",
    "cart.customer_updated",
    "cart.region_updated",
    "cart.updated",
    "customer.created",
    "customer.deleted",
    "customer.updated",
    "delivery.created",
    "invite.accepted",
    "invite.created",
    "invite.deleted",
    "invite.resent",
    "order-edit.canceled",
    "order-edit.confirmed",
    "order-edit.requested",
    "order.archived",
    "order.canceled",
    "order.claim_created",
    "order.completed",
    "order.exchange_created",
    "order.fulfillment_canceled",
    "order.fulfillment_created",
    "order.placed",
    "order.return_received",
    "order.return_requested",
    "order.transfer_requested",
    "order.updated",
    "payment.captured",
    "payment.refunded",
    "product-category.created",
    "product-category.deleted",
    "product-category.updated",
    "product-collection.created",
    "product-collection.deleted",
    "product-collection.updated",
    "product-option.created",
    "product-option.deleted",
    "product-option.updated",
    "product-tag.created",
    "product-tag.deleted",
    "product-tag.updated",
    "product-type.created",
    "product-type.deleted",
    "product-type.updated",
    "product-variant.created",
    "product-variant.deleted",
    "product-variant.updated",
    "product.created",
    "product.deleted",
    "product.updated",
    "region.created",
    "region.deleted",
    "region.updated",
    "sales-channel.created",
    "sales-channel.deleted",
    "sales-channel.updated",
    "shipment.created",
    "shipping-option-type.created",
    "shipping-option-type.deleted",
    "shipping-option-type.updated",
    "shipping-option.created",
    "shipping-option.deleted",
    "shipping-option.updated",
    "translation.created",
    "translation.deleted",
    "translation.updated",
    "user.created",
    "user.deleted",
    "user.updated",
  ],
  context: { subscriberId: "amqp-bridge" },
}
