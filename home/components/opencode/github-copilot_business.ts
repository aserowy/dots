import type { Plugin } from "@opencode-ai/plugin"

const CLIENT_ID = "Ov23li8tweQw6odWQebz"
const OAUTH_POLLING_SAFETY_MARGIN_MS = 3000

function normalizeDomain(url: string) {
  return url.replace(/^https?:\/\//, "").replace(/\/$/, "")
}

function getUrls(domain: string) {
  return {
    DEVICE_CODE_URL: `https://${domain}/login/device/code`,
    ACCESS_TOKEN_URL: `https://${domain}/login/oauth/access_token`,
  }
}

// Cached endpoint from GraphQL discovery
let cachedEndpoint: string | undefined
let endpointFetchedAt = 0
// Re-discover every 30 minutes
const ENDPOINT_CACHE_MS = 30 * 60 * 1000

async function discoverEndpoint(oauthToken: string): Promise<string | undefined> {
  const now = Date.now()
  if (cachedEndpoint && now - endpointFetchedAt < ENDPOINT_CACHE_MS) {
    return cachedEndpoint
  }

  try {
    const response = await fetch("https://api.github.com/graphql", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${oauthToken}`,
        "Content-Type": "application/json",
        "User-Agent": "opencode",
      },
      body: JSON.stringify({
        query: "{ viewer { copilotEndpoints { api } } }",
      }),
    })

    if (!response.ok) return undefined

    const data = (await response.json()) as {
      data?: { viewer?: { copilotEndpoints?: { api?: string } } }
    }

    const endpoint = data?.data?.viewer?.copilotEndpoints?.api
    if (endpoint) {
      cachedEndpoint = endpoint
      endpointFetchedAt = now
    }
    return endpoint
  } catch {
    return undefined
  }
}

function detectRequestContext(body: any, url: string) {
  try {
    // Completions API
    if (body?.messages && url.includes("completions")) {
      return {
        isVision: body.messages.some(
          (msg: any) => Array.isArray(msg.content) && msg.content.some((part: any) => part.type === "image_url"),
        ),
        isAgent: body.messages[body.messages.length - 1]?.role !== "user",
      }
    }

    // Responses API
    if (body?.input) {
      return {
        isVision: body.input.some(
          (item: any) => Array.isArray(item?.content) && item.content.some((part: any) => part.type === "input_image"),
        ),
        isAgent: body.input[body.input.length - 1]?.role !== "user",
      }
    }

    // Messages API
    if (body?.messages) {
      const last = body.messages[body.messages.length - 1]
      const hasNonToolCalls =
        Array.isArray(last?.content) && last.content.some((part: any) => part?.type !== "tool_result")
      return {
        isVision: body.messages.some(
          (item: any) =>
            Array.isArray(item?.content) &&
            item.content.some(
              (part: any) =>
                part?.type === "image" ||
                (part?.type === "tool_result" &&
                  Array.isArray(part?.content) &&
                  part.content.some((nested: any) => nested?.type === "image")),
            ),
        ),
        isAgent: !(last?.role === "user" && hasNonToolCalls),
      }
    }
  } catch {}
  return { isVision: false, isAgent: false }
}

const plugin: Plugin = async (input) => {
  const sdk = input.client
  return {
    auth: {
      provider: "github-copilot",
      async loader(getAuth, provider) {
        const info = await getAuth()
        if (!info || info.type !== "oauth") return {}

        if (provider && provider.models) {
          for (const model of Object.values(provider.models)) {
            model.cost = { input: 0, output: 0, cache: { read: 0, write: 0 } }
            model.api.npm = "@ai-sdk/github-copilot"
          }
        }

        // For enterprise URLs (self-hosted GHE), use the existing copilot-api pattern
        const enterpriseUrl = info.enterpriseUrl
        if (enterpriseUrl) {
          return {
            baseURL: `https://copilot-api.${normalizeDomain(enterpriseUrl)}`,
            apiKey: "",
            async fetch(request: RequestInfo | URL, init?: RequestInit) {
              const info = await getAuth()
              if (info.type !== "oauth") return fetch(request, init)

              const url = request instanceof URL ? request.href : request.toString()
              const body = typeof init?.body === "string" ? JSON.parse(init.body) : init?.body
              const { isVision, isAgent } = detectRequestContext(body, url)

              const headers: Record<string, string> = {
                "x-initiator": isAgent ? "agent" : "user",
                ...(init?.headers as Record<string, string>),
                "User-Agent": "opencode",
                Authorization: `Bearer ${info.refresh}`,
                "Openai-Intent": "conversation-edits",
              }
              if (isVision) headers["Copilot-Vision-Request"] = "true"
              delete headers["x-api-key"]
              delete headers["authorization"]

              return fetch(request, { ...init, headers })
            },
          }
        }

        // For github.com accounts (including Copilot Business/Enterprise Cloud):
        // Discover the correct endpoint via GraphQL. This returns the appropriate
        // API endpoint for the user's account type (e.g. api.enterprise.githubcopilot.com).
        const endpoint = await discoverEndpoint(info.refresh)

        return {
          baseURL: endpoint,
          apiKey: "",
          async fetch(request: RequestInfo | URL, init?: RequestInit) {
            const info = await getAuth()
            if (info.type !== "oauth") return fetch(request, init)

            const url = request instanceof URL ? request.href : request.toString()
            const body = typeof init?.body === "string" ? JSON.parse(init.body) : init?.body
            const { isVision, isAgent } = detectRequestContext(body, url)

            const headers: Record<string, string> = {
              "x-initiator": isAgent ? "agent" : "user",
              ...(init?.headers as Record<string, string>),
              "User-Agent": "opencode",
              Authorization: `Bearer ${info.refresh}`,
              "Openai-Intent": "conversation-edits",
            }
            if (isVision) headers["Copilot-Vision-Request"] = "true"
            delete headers["x-api-key"]
            delete headers["authorization"]

            return fetch(request, { ...init, headers })
          },
        }
      },
      methods: [
        {
          type: "oauth",
          label: "Login with GitHub Copilot",
          prompts: [
            {
              type: "select",
              key: "deploymentType",
              message: "Select GitHub deployment type",
              options: [
                { label: "GitHub.com", value: "github.com", hint: "Public or Enterprise Cloud" },
                { label: "GitHub Enterprise", value: "enterprise", hint: "Data residency or self-hosted" },
              ],
            },
            {
              type: "text",
              key: "enterpriseUrl",
              message: "Enter your GitHub Enterprise URL or domain",
              placeholder: "company.ghe.com or https://company.ghe.com",
              condition: (inputs) => inputs.deploymentType === "enterprise",
              validate: (value) => {
                if (!value) return "URL or domain is required"
                try {
                  const url = value.includes("://") ? new URL(value) : new URL(`https://${value}`)
                  if (!url.hostname) return "Please enter a valid URL or domain"
                  return undefined
                } catch {
                  return "Please enter a valid URL (e.g., company.ghe.com or https://company.ghe.com)"
                }
              },
            },
          ],
          async authorize(inputs = {}) {
            const deploymentType = inputs.deploymentType || "github.com"
            let domain = "github.com"
            let actualProvider = "github-copilot"

            if (deploymentType === "enterprise") {
              domain = normalizeDomain(inputs.enterpriseUrl!)
              actualProvider = "github-copilot-enterprise"
            }

            const urls = getUrls(domain)
            const deviceResponse = await fetch(urls.DEVICE_CODE_URL, {
              method: "POST",
              headers: {
                Accept: "application/json",
                "Content-Type": "application/json",
                "User-Agent": "opencode",
              },
              body: JSON.stringify({ client_id: CLIENT_ID, scope: "read:user" }),
            })

            if (!deviceResponse.ok) throw new Error("Failed to initiate device authorization")

            const deviceData = (await deviceResponse.json()) as {
              verification_uri: string
              user_code: string
              device_code: string
              interval: number
            }

            return {
              url: deviceData.verification_uri,
              instructions: `Enter code: ${deviceData.user_code}`,
              method: "auto" as const,
              async callback() {
                while (true) {
                  const response = await fetch(urls.ACCESS_TOKEN_URL, {
                    method: "POST",
                    headers: {
                      Accept: "application/json",
                      "Content-Type": "application/json",
                      "User-Agent": "opencode",
                    },
                    body: JSON.stringify({
                      client_id: CLIENT_ID,
                      device_code: deviceData.device_code,
                      grant_type: "urn:ietf:params:oauth:grant-type:device_code",
                    }),
                  })

                  if (!response.ok) return { type: "failed" as const }

                  const data = (await response.json()) as {
                    access_token?: string
                    error?: string
                    interval?: number
                  }

                  if (data.access_token) {
                    const result: {
                      type: "success"
                      refresh: string
                      access: string
                      expires: number
                      provider?: string
                      enterpriseUrl?: string
                    } = {
                      type: "success",
                      refresh: data.access_token,
                      access: data.access_token,
                      expires: 0,
                    }

                    if (actualProvider === "github-copilot-enterprise") {
                      result.provider = "github-copilot-enterprise"
                      result.enterpriseUrl = domain
                    }

                    return result
                  }

                  if (data.error === "authorization_pending") {
                    await Bun.sleep(deviceData.interval * 1000 + OAUTH_POLLING_SAFETY_MARGIN_MS)
                    continue
                  }

                  if (data.error === "slow_down") {
                    let newInterval = (deviceData.interval + 5) * 1000
                    if (data.interval && typeof data.interval === "number" && data.interval > 0) {
                      newInterval = data.interval * 1000
                    }
                    await Bun.sleep(newInterval + OAUTH_POLLING_SAFETY_MARGIN_MS)
                    continue
                  }

                  if (data.error) return { type: "failed" as const }

                  await Bun.sleep(deviceData.interval * 1000 + OAUTH_POLLING_SAFETY_MARGIN_MS)
                  continue
                }
              },
            }
          },
        },
      ],
    },
    "chat.headers": async (incoming, output) => {
      if (!incoming.model.providerID.includes("github-copilot")) return

      if (incoming.model.api.npm === "@ai-sdk/anthropic") {
        output.headers["anthropic-beta"] = "interleaved-thinking-2025-05-14"
      }

      const session = await sdk.session
        .get({
          path: { id: incoming.sessionID },
          query: { directory: input.directory },
          throwOnError: true,
        })
        .catch(() => undefined)
      if (!session || !session.data.parentID) return
      output.headers["x-initiator"] = "agent"
    },
  }
}

export default plugin
