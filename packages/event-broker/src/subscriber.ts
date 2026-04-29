import * as amqp from "amqplib"
import { BrokerConfig, BrokerMessage, MessageHandler } from "./types"

const DEFAULT_EXCHANGE = "medusa.events"

export class AmqpSubscriber {
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

  async subscribe(bindingPattern: string, handler: MessageHandler): Promise<void> {
    if (!this.channel) {
      throw new Error("AmqpSubscriber: call connect() before subscribe()")
    }

    const { queue } = await this.channel.assertQueue("", { exclusive: true })
    await this.channel.bindQueue(queue, this.config.exchange, bindingPattern)

    this.channel.consume(queue, async (raw) => {
      if (!raw) return
      try {
        const msg: BrokerMessage = JSON.parse(raw.content.toString())
        await handler(msg)
        this.channel!.ack(raw)
      } catch (err) {
        this.channel!.nack(raw, false, false)
      }
    })
  }

  async close(): Promise<void> {
    await this.channel?.close()
    await this.connection?.close()
    this.channel = null
    this.connection = null
  }
}
