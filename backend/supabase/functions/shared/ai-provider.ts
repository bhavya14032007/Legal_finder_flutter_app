// Modular AI Provider Abstraction for Legal Helper
// Supports Google Gemini, OpenAI, Anthropic, Groq, OpenRouter, and custom OpenAI-compatible APIs

export interface ChatMessage {
  role: "system" | "user" | "assistant";
  content: string;
}

export interface CompletionOptions {
  systemPrompt?: string;
  messages: ChatMessage[];
  temperature?: number;
  maxTokens?: number;
  jsonMode?: boolean;
  timeoutMs?: number;
}

export interface CompletionResult {
  text: string;
  provider: string;
  model: string;
  usage?: {
    promptTokens?: number;
    completionTokens?: number;
    totalTokens?: number;
  };
}

export class AIProviderService {
  private provider: string;
  private apiKey: string;
  private model: string;
  private baseUrl?: string;

  constructor() {
    this.provider = (Deno.env.get("AI_PROVIDER") || "gemini").toLowerCase();

    switch (this.provider) {
      case "gemini":
      case "google":
        this.provider = "gemini";
        this.apiKey = Deno.env.get("GEMINI_API_KEY") || "";
        this.model = Deno.env.get("GEMINI_MODEL") || "gemini-1.5-flash";
        break;

      case "openai":
        this.apiKey = Deno.env.get("OPENAI_API_KEY") || "";
        this.model = Deno.env.get("OPENAI_MODEL") || "gpt-4o-mini";
        this.baseUrl = Deno.env.get("OPENAI_BASE_URL") || "https://api.openai.com/v1";
        break;

      case "anthropic":
        this.apiKey = Deno.env.get("ANTHROPIC_API_KEY") || "";
        this.model = Deno.env.get("ANTHROPIC_MODEL") || "claude-3-5-sonnet-20241022";
        break;

      case "groq":
        this.provider = "openai_compatible";
        this.apiKey = Deno.env.get("GROQ_API_KEY") || "";
        this.model = Deno.env.get("GROQ_MODEL") || "llama-3.3-70b-versatile";
        this.baseUrl = "https://api.groq.com/openai/v1";
        break;

      case "grok":
      case "xai":
        this.provider = "openai_compatible";
        this.apiKey = Deno.env.get("GROK_API_KEY") || Deno.env.get("GROQ_API_KEY") || "";
        this.model = Deno.env.get("GROK_MODEL") || "grok-beta";
        this.baseUrl = "https://api.x.ai/v1";
        break;

      case "openrouter":
        this.provider = "openai_compatible";
        this.apiKey = Deno.env.get("OPENROUTER_API_KEY") || "";
        this.model = Deno.env.get("OPENROUTER_MODEL") || "anthropic/claude-3.5-sonnet";
        this.baseUrl = "https://openrouter.ai/api/v1";
        break;

      case "custom":
        this.provider = "openai_compatible";
        this.apiKey = Deno.env.get("CUSTOM_AI_API_KEY") || "";
        this.model = Deno.env.get("CUSTOM_AI_MODEL") || "custom-model";
        this.baseUrl = Deno.env.get("CUSTOM_AI_BASE_URL") || "http://localhost:11434/v1";
        break;

      default:
        this.provider = "gemini";
        this.apiKey = Deno.env.get("GEMINI_API_KEY") || "";
        this.model = Deno.env.get("GEMINI_MODEL") || "gemini-1.5-flash";
    }
  }

  public async generateCompletion(options: CompletionOptions): Promise<CompletionResult> {
    const timeoutMs = options.timeoutMs || 45000;
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

    try {
      if (!this.apiKey) {
        throw new Error(
          `AI Provider '${this.provider}' API key is not configured. Please set the appropriate environment variable.`
        );
      }

      if (this.provider === "gemini") {
        return await this.callGemini(options, controller.signal);
      } else if (this.provider === "anthropic") {
        return await this.callAnthropic(options, controller.signal);
      } else {
        // OpenAI or OpenAI-compatible (Groq, OpenRouter, Custom)
        return await this.callOpenAICompatible(options, controller.signal);
      }
    } catch (err: unknown) {
      if ((err as Error)?.name === "AbortError") {
        throw new Error(`AI request timed out after ${timeoutMs / 1000} seconds`);
      }
      throw err;
    } finally {
      clearTimeout(timeoutId);
    }
  }

  // Google Gemini API integration
  private async callGemini(options: CompletionOptions, signal: AbortSignal): Promise<CompletionResult> {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${this.model}:generateContent?key=${this.apiKey}`;

    const contents = options.messages
      .filter((m) => m.role !== "system")
      .map((m) => ({
        role: m.role === "assistant" ? "model" : "user",
        parts: [{ text: m.content }],
      }));

    const systemInstruction = options.systemPrompt
      ? { parts: [{ text: options.systemPrompt }] }
      : undefined;

    const payload: Record<string, unknown> = {
      contents,
      generationConfig: {
        temperature: options.temperature ?? 0.2,
        maxOutputTokens: options.maxTokens ?? 2500,
        responseMimeType: options.jsonMode ? "application/json" : "text/plain",
      },
    };

    if (systemInstruction) {
      payload.systemInstruction = systemInstruction;
    }

    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
      signal,
    });

    if (!response.ok) {
      const errText = await response.text();
      throw new Error(`Gemini API error (${response.status}): ${this.sanitizeError(errText)}`);
    }

    const json = await response.json();
    const candidate = json.candidates?.[0];
    const text = candidate?.content?.parts?.[0]?.text || "";

    return {
      text,
      provider: "google-gemini",
      model: this.model,
      usage: {
        promptTokens: json.usageMetadata?.promptTokenCount,
        completionTokens: json.usageMetadata?.candidatesTokenCount,
        totalTokens: json.usageMetadata?.totalTokenCount,
      },
    };
  }

  // OpenAI / Compatible API integration
  private async callOpenAICompatible(options: CompletionOptions, signal: AbortSignal): Promise<CompletionResult> {
    const endpoint = `${this.baseUrl || "https://api.openai.com/v1"}/chat/completions`;

    const messages = [];
    if (options.systemPrompt) {
      messages.push({ role: "system", content: options.systemPrompt });
    }
    for (const msg of options.messages) {
      messages.push({ role: msg.role, content: msg.content });
    }

    const body: Record<string, unknown> = {
      model: this.model,
      messages,
      temperature: options.temperature ?? 0.2,
      max_tokens: options.maxTokens ?? 2500,
    };

    if (options.jsonMode) {
      body.response_format = { type: "json_object" };
    }

    const response = await fetch(endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify(body),
      signal,
    });

    if (!response.ok) {
      const errText = await response.text();
      throw new Error(`AI API error (${response.status}): ${this.sanitizeError(errText)}`);
    }

    const json = await response.json();
    const text = json.choices?.[0]?.message?.content || "";

    return {
      text,
      provider: this.provider,
      model: this.model,
      usage: {
        promptTokens: json.usage?.prompt_tokens,
        completionTokens: json.usage?.completion_tokens,
        totalTokens: json.usage?.total_tokens,
      },
    };
  }

  // Anthropic Claude integration
  private async callAnthropic(options: CompletionOptions, signal: AbortSignal): Promise<CompletionResult> {
    const endpoint = "https://api.anthropic.com/v1/messages";

    const messages = options.messages
      .filter((m) => m.role !== "system")
      .map((m) => ({
        role: m.role === "assistant" ? "assistant" : "user",
        content: m.content,
      }));

    const body: Record<string, unknown> = {
      model: this.model,
      messages,
      max_tokens: options.maxTokens ?? 2500,
      temperature: options.temperature ?? 0.2,
    };

    if (options.systemPrompt) {
      body.system = options.systemPrompt;
    }

    const response = await fetch(endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": this.apiKey,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify(body),
      signal,
    });

    if (!response.ok) {
      const errText = await response.text();
      throw new Error(`Anthropic API error (${response.status}): ${this.sanitizeError(errText)}`);
    }

    const json = await response.json();
    const text = json.content?.[0]?.text || "";

    return {
      text,
      provider: "anthropic",
      model: this.model,
      usage: {
        promptTokens: json.usage?.input_tokens,
        completionTokens: json.usage?.output_tokens,
        totalTokens: (json.usage?.input_tokens || 0) + (json.usage?.output_tokens || 0),
      },
    };
  }

  // Sanitize errors to guarantee API keys are never leaked in logs or client responses
  private sanitizeError(raw: string): string {
    return raw
      .replace(new RegExp(this.apiKey, "gi"), "[REDACTED_API_KEY]")
      .slice(0, 500);
  }
}

