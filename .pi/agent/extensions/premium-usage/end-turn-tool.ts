/**
 * end_turn Tool — execute loop and exit-command dispatch.
 *
 * Flow:
 * 1. Open pi's built-in editor dialog
 * 2. User types text → return as tool result
 * 3. User submits a slash command → handle it, then re-open the editor
 * 4. User presses Esc → return, agent will call end_turn again
 * 5. User runs /end → return, agent stops calling end_turn
 *
 * Compact deadlock prevention:
 * /compact triggers ctx.compact() → session.compact() → agent.abort() → waitForIdle().
 * waitForIdle() blocks until end_turn.execute() returns, creating a circular dependency.
 * Fix: handleCompact races the compact promise against the agent abort signal. When
 * abort fires, we break out immediately, the tool returns a result, waitForIdle()
 * unblocks, and compaction can complete. The execute loop checks _signal.aborted to
 * avoid looping back into the UI while the agent is shutting down.
 *
 * Post-compact end_turn (cheaper restart):
 * handleCompact calls onCompactStart() before triggering compact. index.ts listens for
 * session_compact and re-shows the built-in editor directly, then calls
 * pi.sendUserMessage(answer) with the user's real response. This costs 1 premium
 * request instead of 2 (old approach: sendUserMessage→agent calls end_turn→answer).
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { Text } from "@mariozechner/pi-tui";
import { dispatchCommand, type CommandContext } from "./commands.js";

const END_TURN_EDITOR_TITLE = "Reply";

// ── Types ──────────────────────────────────────────────────────────────

interface ToolResult {
  content: { type: "text"; text: string }[];
  details: { answer: string | null };
}

export type EndTurnInputResult =
  | { type: "answer"; text: string }
  | { type: "exit-command"; command: string; args?: string }
  | null;

// ── Shared Input Collection ────────────────────────────────────────────

export async function collectEndTurnInput(
  pi: ExtensionAPI,
  ctx: any,
  getStats: () => { requestCount: number; savedCount: number },
): Promise<EndTurnInputResult> {
  while (true) {
    const value = await ctx.ui.editor(END_TURN_EDITOR_TITLE, "");
    if (value === null) return null;

    const trimmed = value.trim();
    if (!trimmed) continue;

    if (!trimmed.startsWith("/")) {
      return { type: "answer", text: trimmed };
    }

    const stats = getStats();
    const cmdCtx: CommandContext = {
      pi,
      ctx,
      requestCount: stats.requestCount,
      savedCount: stats.savedCount,
    };
    const result = dispatchCommand(trimmed, cmdCtx);

    if (!result) {
      ctx.ui.notify(`Unknown command: ${trimmed}`, "error");
      continue;
    }

    if (result.type === "inline") {
      ctx.ui.notify(
        result.statusMessage,
        result.statusMessage.startsWith("✗") ? "error" : "info",
      );
      continue;
    }

    return { type: "exit-command", command: result.command, args: result.args };
  }
}

// ── Tool Registration ──────────────────────────────────────────────────

/**
 * Register the end_turn tool on the given extension API.
 *
 * @param pi              - Extension API
 * @param getStats        - Returns current { requestCount, savedCount }
 * @param onAnswer        - Called when user submits text (to increment savedCount)
 * @param onCompactStart  - Called when /compact is triggered. Used by the
 *                          session_compact handler in index.ts to re-show the
 *                          editor directly after compaction (saving 1 premium request).
 */
export function registerEndTurnTool(
  pi: ExtensionAPI,
  getStats: () => { requestCount: number; savedCount: number },
  onAnswer: (ctx: any) => void,
  onCompactStart?: () => void,
) {
  pi.registerTool({
    name: "end_turn",
    label: "End Turn",
    description:
      "End your turn and wait for the user's next message. Call this after each assistant response following the initial user message.",
    promptSnippet: "After each assistant response, call end_turn()",
    promptGuidelines: [
      "After each assistant response, call end_turn().",
      "Write the full assistant response before calling end_turn().",
      "If you need clarification, ask in the assistant message, then call end_turn().",
      "Treat the tool result as the user's next normal message.",
    ],
    parameters: Type.Object({}),

    async execute(
      _toolCallId,
      _params,
      _signal,
      _onUpdate,
      ctx,
    ): Promise<ToolResult> {
      if (!ctx.hasUI) {
        return {
          content: [
            {
              type: "text",
              text: "No UI available — running in non-interactive mode",
            },
          ],
          details: { answer: null },
        };
      }

      while (true) {
        let answer: EndTurnInputResult;

        try {
          answer = await collectEndTurnInput(pi, ctx, getStats);
        } catch (err) {
          return {
            content: [
              {
                type: "text",
                text: `[end_turn editor error: ${err}. Call end_turn again.]`,
              },
            ],
            details: { answer: null },
          };
        }

        if (answer === null) {
          return {
            content: [
              {
                type: "text",
                text: "[User pressed Esc to access pi commands. Call end_turn again when ready for input.]",
              },
            ],
            details: { answer: null },
          };
        }

        if (answer.type === "answer") {
          onAnswer(ctx);
          return {
            content: [{ type: "text", text: answer.text }],
            details: { answer: answer.text },
          };
        }

        const result = await handleExitCommand(
          answer.command,
          answer.args,
          pi,
          ctx,
          _signal,
          onCompactStart,
        );
        if (result)
          return { ...result, details: { answer: result.answerText } };

        if (_signal?.aborted) {
          return {
            content: [
              {
                type: "text",
                text: "[Context compaction in progress. Call end_turn again when ready to continue.]",
              },
            ],
            details: { answer: null },
          };
        }
      }
    },

    renderCall(_args: any, theme: any) {
      return new Text(theme.fg("dim", "↳ waiting"), 0, 0);
    },

    renderResult(result: any, _options: any, theme: any) {
      const details = result.details as { answer: string | null } | undefined;

      if (!details?.answer) {
        return new Text(theme.fg("dim", "↳ no reply"), 0, 0);
      }
      if (details.answer === "/end") {
        return new Text(theme.fg("warning", "↳ premium saver ended"), 0, 0);
      }
      return new Text(
        theme.fg("dim", "↳ ") + theme.fg("text", details.answer),
        0,
        0,
      );
    },
  });
}

// ── Exit Command Handlers ──────────────────────────────────────────────

interface ExitCommandResult {
  content: { type: "text"; text: string }[];
  answerText: string | null;
}

/**
 * Handle commands that require leaving the editor loop first.
 * Returns a tool result to return from execute(), or null to continue the loop.
 */
async function handleExitCommand(
  command: string,
  args: string | undefined,
  pi: ExtensionAPI,
  ctx: any,
  signal?: AbortSignal | null,
  onCompactStart?: () => void,
): Promise<ExitCommandResult | null> {
  switch (command) {
    case "end":
      return {
        content: [
          {
            type: "text",
            text: "[User ended the premium-usage session with /end. Do NOT call end_turn. Respond normally and let the user send their next message via the regular editor. The next message will cost a premium request.]",
          },
        ],
        answerText: "/end",
      };

    case "compact":
      return handleCompact(args, signal, ctx, onCompactStart);

    case "model-select":
      return handleModelSelect(pi, ctx);

    case "model-switch":
      return handleModelSwitch(args || "", pi, ctx);

    default:
      ctx.ui.notify(`Unknown exit command: ${command}`, "error");
      return null;
  }
}

async function handleCompact(
  args: string | undefined,
  signal: AbortSignal | null | undefined,
  ctx: any,
  onCompactStart?: () => void,
): Promise<ExitCommandResult | null> {
  try {
    onCompactStart?.();
    const compactPromise = new Promise<string>((resolve, reject) => {
      ctx.compact({
        customInstructions: args || undefined,
        onComplete: () => {
          resolve("✓ Compaction complete");
        },
        onError: (err: Error) => reject(err),
      });
    });

    const abortPromise = new Promise<never>((_, reject) => {
      if (signal?.aborted) {
        reject(new Error("aborted"));
        return;
      }
      signal?.addEventListener("abort", () => reject(new Error("aborted")), {
        once: true,
      });
    });

    const result = await Promise.race([compactPromise, abortPromise]);
    ctx.ui.notify(result, "info");
  } catch (err: any) {
    if (err.message !== "aborted") {
      ctx.ui.notify(`✗ Compaction failed: ${err.message}`, "error");
    }
  }
  return null;
}

async function handleModelSelect(
  pi: ExtensionAPI,
  ctx: any,
): Promise<ExitCommandResult | null> {
  try {
    const models = ctx.modelRegistry.getAvailable();
    const labels = models.map((m: any) => `${m.provider}/${m.id}`);

    const beforeModel = ctx.model;
    const selected = await ctx.ui.select("Select model:", labels);

    if (selected !== undefined) {
      const model = models.find(
        (m: any) => `${m.provider}/${m.id}` === selected,
      );
      if (model) {
        const success = await pi.setModel(model);
        const afterModel = ctx.model;
        ctx.ui.notify(
          success
            ? `✓ Switched to ${model.provider}/${model.id} (was: ${beforeModel?.id ?? "none"}, now: ${afterModel?.id ?? "none"})`
            : `✗ No API key for ${model.provider}/${model.id}`,
          success ? "info" : "error",
        );
      }
    }
  } catch (err: any) {
    ctx.ui.notify(`Model selection error: ${err.message}`, "error");
  }
  return null;
}

async function handleModelSwitch(
  query: string,
  pi: ExtensionAPI,
  ctx: any,
): Promise<ExitCommandResult | null> {
  try {
    const models = ctx.modelRegistry.getAvailable();
    const match = models.find(
      (m: any) =>
        m.id.toLowerCase().includes(query.toLowerCase()) ||
        m.name?.toLowerCase().includes(query.toLowerCase()),
    );

    const beforeModel = ctx.model;
    if (match) {
      const success = await pi.setModel(match);
      const afterModel = ctx.model;
      ctx.ui.notify(
        success
          ? `✓ Switched to ${match.provider}/${match.id} (was: ${beforeModel?.id ?? "none"}, now: ${afterModel?.id ?? "none"})`
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
  return null;
}
