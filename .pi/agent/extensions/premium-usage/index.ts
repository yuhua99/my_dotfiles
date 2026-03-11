/**
 * Premium Request Saver Extension
 *
 * Exploits the fact that tool results are NOT billed as premium requests.
 * Only the first user message costs 1 premium request. After that, all
 * user input is collected via an "end_turn" tool call, so responses come
 * back as tool results (free).
 *
 * The agent is instructed via system prompt to ALWAYS use end_turn when
 * it needs user input, and to call it at the end of every response.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { collectEndTurnInput, registerEndTurnTool, type EndTurnInputResult } from "./end-turn-tool.js";

export default function (pi: ExtensionAPI) {
  // ── State ──────────────────────────────────────────────────────────

  let requestCount = 0;
  let savedCount = 0;
  let pendingPostCompactEndTurn = false;

  // ── Helpers ────────────────────────────────────────────────────────

  /** Count requests and savings from the current session branch. */
  function countFromBranch(ctx: { sessionManager: { getBranch(): any[] } }): {
    requests: number;
    saved: number;
  } {
    let requests = 0;
    let saved = 0;
    for (const entry of ctx.sessionManager.getBranch()) {
      if (entry.type === "message" && entry.message?.role === "user") {
        requests++;
      }
      if (
        entry.type === "message" &&
        entry.message?.role === "toolResult" &&
        entry.message?.toolName === "end_turn" &&
        entry.message?.details?.answer != null
      ) {
        saved++;
      }
    }
    return { requests, saved };
  }

  /** Update the status bar with current usage stats. */
  function updateStatus(ctx: any) {
    const theme = ctx.ui.theme;
    const icon = theme.fg("accent", "⚡");
    const req = theme.fg("dim", `${requestCount} used`);
    const save = theme.fg("success", `${savedCount} saved`);
    ctx.ui.setStatus(
      "premium-usage",
      `${icon} ${req} ${theme.fg("dim", "·")} ${save}`,
    );
  }

  // ── Event Handlers ─────────────────────────────────────────────────

  pi.on("turn_start", async (_event, ctx) => {
    const model = ctx.model;
    console.error(`[DEBUG turn_start] Model: ${model?.provider}/${model?.id}`);
  });

  pi.on("session_start", async (_event, ctx) => {
    const counts = countFromBranch(ctx);
    requestCount = counts.requests;
    savedCount = counts.saved;
    updateStatus(ctx);
  });

  pi.on("session_switch", async (_event, ctx) => {
    const counts = countFromBranch(ctx);
    requestCount = counts.requests;
    savedCount = counts.saved;
    updateStatus(ctx);
  });

  pi.on("message_start", async (event, ctx) => {
    if (event.message.role === "user") {
      requestCount++;
      updateStatus(ctx);
    }
  });

  pi.on("input", async (event, ctx) => {
    if (event.source === "extension") return { action: "continue" as const };
    if (requestCount <= 1) return { action: "continue" as const };

    ctx.ui.notify("⚠️ This message costs a premium request!", "warning");
    return { action: "continue" as const };
  });

  pi.on("before_agent_start", async (event, _ctx) => {
    return {
      systemPrompt:
        event.systemPrompt +
        `

## CRITICAL: User Interaction Rule

After the initial user message, end each assistant response with \`end_turn()\`.

This is mandatory because each normal user message costs a premium request, but tool results are free. By using \`end_turn\`, the entire session costs only 1 premium request.

**Rules:**
1. Write the full assistant response first
2. Then call \`end_turn()\`
3. If you need clarification, ask in the assistant message, then call \`end_turn()\`
4. Treat the tool result as the user's next normal message
`,
    };
  });

  // After compaction, re-open the built-in editor directly and send the user's
  // answer as the first message of the new session. This saves 1 premium request
  // compared to sendUserMessage → agent turn → agent calls end_turn → answer.
  pi.on("session_compact", async (_event, ctx) => {
    if (!pendingPostCompactEndTurn || !ctx.hasUI) return;
    pendingPostCompactEndTurn = false;

    while (true) {
      let answer: EndTurnInputResult;
      try {
        answer = await collectEndTurnInput(pi, ctx, () => ({ requestCount, savedCount }));
      } catch (err: any) {
        ctx.ui.notify(`end_turn editor error: ${err.message ?? err}`, "error");
        ctx.ui.notify("Type your next message normally to continue.", "warning");
        return;
      }

      if (answer === null) continue;

      if (answer.type === "answer") {
        savedCount++;
        updateStatus(ctx);
        pi.sendUserMessage(answer.text);
        return;
      }

      if (answer.type === "exit-command") {
        if (answer.command === "end") {
          return;
        }
        if (answer.command === "compact") {
          ctx.ui.notify("Already compacted. Send your message first.", "warning");
          continue;
        }
        if (answer.command === "model-select") {
          try {
            const models = ctx.modelRegistry.getAvailable();
            const labels = models.map((m: any) => `${m.provider}/${m.id}`);
            const selected = await ctx.ui.select("Select model:", labels);
            if (selected !== undefined) {
              const model = models.find(
                (m: any) => `${m.provider}/${m.id}` === selected,
              );
              if (model) {
                const success = await pi.setModel(model);
                ctx.ui.notify(
                  success
                    ? `✓ Switched to ${model.provider}/${model.id}`
                    : `✗ No API key for ${model.provider}/${model.id}`,
                  success ? "info" : "error",
                );
              }
            }
          } catch (err: any) {
            ctx.ui.notify(`Model selection error: ${err.message}`, "error");
          }
          continue;
        }
        if (answer.command === "model-switch") {
          try {
            const models = ctx.modelRegistry.getAvailable();
            const query = answer.args || "";
            const match = models.find(
              (m: any) =>
                m.id.toLowerCase().includes(query.toLowerCase()) ||
                m.name?.toLowerCase().includes(query.toLowerCase()),
            );
            if (match) {
              const success = await pi.setModel(match);
              ctx.ui.notify(
                success
                  ? `✓ Switched to ${match.provider}/${match.id}`
                  : `✗ No API key for ${match.provider}/${match.id}`,
                success ? "info" : "error",
              );
            } else {
              const names = models
                .map((m: any) => `${m.provider}/${m.id}`)
                .slice(0, 15)
                .join(", ");
              ctx.ui.notify(
                `✗ No model matching "${query}". Available: ${names}${models.length > 15 ? "..." : ""}`,
                "error",
              );
            }
          } catch (err: any) {
            ctx.ui.notify(`Model switch error: ${err.message}`, "error");
          }
          continue;
        }

        ctx.ui.notify(`Unknown command: ${answer.command}`, "error");
        continue;
      }
    }
  });

  // ── Tool Registration ──────────────────────────────────────────────

  registerEndTurnTool(
    pi,
    () => ({ requestCount, savedCount }),
    (ctx) => {
      savedCount++;
      updateStatus(ctx);
    },
    () => {
      pendingPostCompactEndTurn = true;
    },
  );

  // ── Commands (for main editor) ─────────────────────────────────────

  pi.registerCommand("usage", {
    description: "Show premium request usage for this session",
    handler: async (_args, ctx) => {
      const usage = ctx.getContextUsage();
      const contextInfo =
        usage && usage.tokens !== null
          ? `Context: ${(usage.tokens / 1000).toFixed(1)}k / ${(usage.contextWindow / 1000).toFixed(0)}k tokens (${((usage.tokens / usage.contextWindow) * 100).toFixed(1)}%)`
          : "Context: unknown";

      ctx.ui.notify(
        `⚡ Premium requests used: ${requestCount}\n💰 Requests saved: ${savedCount}\n${contextInfo}`,
        "info",
      );
    },
  });
}
