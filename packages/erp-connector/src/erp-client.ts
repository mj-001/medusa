import axios, { AxiosInstance } from "axios"
import { ERPNextConfig } from "./types"

export class ERPClient {
  private client: AxiosInstance
  private site: string

  constructor(config: ERPNextConfig) {
    this.site = config.site
    this.client = axios.create({
      baseURL: config.url,
      headers: {
        Authorization: `token ${config.apiKey}:${config.apiSecret}`,
        "X-Frappe-Site-Name": config.site,
        "Content-Type": "application/json",
      },
      timeout: 15_000,
    })
  }

  async create<T extends { doctype: string }>(doc: T): Promise<Record<string, unknown>> {
    const res = await this.client.post("/api/resource/" + doc.doctype, doc)
    return res.data.data
  }

  async update(
    doctype: string,
    name: string,
    patch: Record<string, unknown>
  ): Promise<Record<string, unknown>> {
    const res = await this.client.put(
      `/api/resource/${encodeURIComponent(doctype)}/${encodeURIComponent(name)}`,
      patch
    )
    return res.data.data
  }

  async get(doctype: string, name: string): Promise<Record<string, unknown> | null> {
    try {
      const res = await this.client.get(
        `/api/resource/${encodeURIComponent(doctype)}/${encodeURIComponent(name)}`
      )
      return res.data.data
    } catch (err: unknown) {
      if (axios.isAxiosError(err) && err.response?.status === 404) return null
      throw err
    }
  }

  async findByField(
    doctype: string,
    field: string,
    value: string
  ): Promise<Record<string, unknown> | null> {
    const filters = JSON.stringify([[doctype, field, "=", value]])
    const res = await this.client.get(
      `/api/resource/${encodeURIComponent(doctype)}?filters=${encodeURIComponent(filters)}&limit=1`
    )
    const list: Array<{ name: string }> = res.data.data ?? []
    if (!list.length) return null
    return this.get(doctype, list[0].name)
  }

  async upsertByField(
    doctype: string,
    field: string,
    value: string,
    doc: Record<string, unknown>
  ): Promise<Record<string, unknown>> {
    const existing = await this.findByField(doctype, field, value)
    if (existing) {
      return this.update(doctype, existing["name"] as string, doc)
    }
    return this.create(doc as { doctype: string })
  }

  async cancel(doctype: string, name: string): Promise<void> {
    await this.client.post(
      `/api/resource/${encodeURIComponent(doctype)}/${encodeURIComponent(name)}/Cancel`
    )
  }

  async submit(doctype: string, name: string): Promise<void> {
    await this.client.post(
      `/api/resource/${encodeURIComponent(doctype)}/${encodeURIComponent(name)}/Submit`
    )
  }
}
