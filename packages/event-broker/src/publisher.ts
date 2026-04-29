import * as amqp from "amqplib"
import { BrokerConfig, BrokerMessage } from "./types"

const DEFAULT_EXCHANGE = "medusa.events"

export class AmqpPublisher {
  private config: Required<BrokerConfig>
  private connection: amqp.Connection | null = null
  private channel: amqp.Channel | null = null

  constructor(config: BrokerConfig) {
    this.config = {
      url: config.url,
      exchange: config.exchange ?? DEFAULT_EXCHANGE,
    }
  }

  async connect(): Promise<void> {
    this.connection = await amqp.connect(this.config.url)
    this.channel = await this.connection.createChannel()
    await this.channel.assertExchange(this.config.exchange, "topic", {
      durable: true,
    })
  }

  async publish(routingKey: string, payload: unknown): Promise<void> {
    if (!this.channel) {
      throw new Error("AmqpPublisher: call connect() before publish()")
    }

    const message: BrokerMessage = {
      event: routingKey,
      data: payload,
      timestamp: new Date().toISOString(),
    }

    const buffer = Buffer.from(JSON.stringify(message))
    this.channel.publish(this.config.exchange, routingKey, buffer, {
      persistent: true,
      contentType: "application/json",
    })
  }

  async close(): Promise<void> {
    await this.channel?.close()
    await this.connection?.close()
    this.channel = null
    this.connection = null
  }
}
