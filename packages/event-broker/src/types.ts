export interface BrokerConfig {
  url: string
  exchange?: string
}

export interface BrokerMessage {
  event: string
  data: unknown
  timestamp: string
}

export type MessageHandler = (msg: BrokerMessage) => void | Promise<void>
