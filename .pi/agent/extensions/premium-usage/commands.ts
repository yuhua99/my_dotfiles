/**
 * Command Registry for the end_turn tool.
 *
 * Each command defines:
 * - name & description (for autocomplete + help)
 * - inline: whether it runs inside the custom UI (true) or exits first (false)
 * - handler: the function to execute
 *
 * Inline commands show a status message and keep the editor open.
 * Non-inline commands return a result that the execute loop handles.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import type { SlashCommand } from "@mariozechner/pi-tui";

// ── Types ──────────────────────────────────────────────────────────────

/** Result from an inline command (stays in editor). */
export interface InlineResult {
	type: "inline";
	statusMessage: string;
}

/** Result from a command that exits the custom UI. */
export interface ExitResult {
	type: "exit";
	command: string;
	args?: string;
}

export type CommandResult = InlineResult | ExitResult;

/** Context available to command handlers. */
export interface CommandContext {
	pi: ExtensionAPI;
	ctx: any; // ExtensionContext from tool execute
	requestCount: number;
	savedCount: number;
}

export interface CommandDef {
	name: string;
	description: string;
	handler: (args: string, cmdCtx: CommandContext) => CommandResult;
}

// ── Helpers ────────────────────────────────────────────────────────────

function inline(statusMessage: string): InlineResult {
	return { type: "inline", statusMessage };
}

function exit(command: string, args?: string): ExitResult {
	return { type: "exit", command, args };
}

/** Format token count safely (handles null from post-compaction state). */
function formatTokens(tokens: number | null): string {
	if (tokens === null) return "unknown";
	return `${(tokens / 1000).toFixed(1)}k`;
}

// ── Command Handlers ───────────────────────────────────────────────────

function usageHandler(_args: string, { ctx, requestCount, savedCount }: CommandContext): CommandResult {
	const usage = ctx.getContextUsage();
	let msg = `⚡ ${requestCount} used · 💰 ${savedCount} saved`;
	if (usage) {
		const tokens = formatTokens(usage.tokens);
		const limit = `${(usage.contextWindow / 1000).toFixed(0)}k`;
		const pct = usage.percent !== null ? ` (${usage.percent.toFixed(1)}%)` : "";
		msg += ` · Context: ${tokens} / ${limit}${pct}`;
	}
	return inline(msg);
}

function compactHandler(args: string, _cmdCtx: CommandContext): CommandResult {
	return exit("compact", args || undefined);
}

function endHandler(_args: string, _cmdCtx: CommandContext): CommandResult {
	return exit("end");
}

function modelHandler(args: string, _cmdCtx: CommandContext): CommandResult {
	if (!args) {
		return exit("model-select");
	}
	return exit("model-switch", args);
}

function toolsHandler(args: string, { pi }: CommandContext): CommandResult {
	const active = pi.getActiveTools();
	const all = pi.getAllTools();

	if (!args) {
		const activeNames = active.join(", ");
		const allNames = all.map((t: any) => t.name);
		const inactive = allNames.filter((n: string) => !active.includes(n));
		return inline(`🔧 Active: ${activeNames}${inactive.length ? ` · Inactive: ${inactive.join(", ")}` : ""}`);
	}

	const newActive = [...active];
	const changes: string[] = [];
	for (const token of args.split(/\s+/)) {
		if (token.startsWith("+")) {
			const name = token.slice(1);
			if (!newActive.includes(name)) {
				newActive.push(name);
				changes.push(`+${name}`);
			}
		} else if (token.startsWith("-")) {
			const name = token.slice(1);
			const idx = newActive.indexOf(name);
			if (idx >= 0) {
				newActive.splice(idx, 1);
				changes.push(`-${name}`);
			}
		} else {
			const idx = newActive.indexOf(token);
			if (idx >= 0) {
				newActive.splice(idx, 1);
				changes.push(`-${token}`);
			} else {
				newActive.push(token);
				changes.push(`+${token}`);
			}
		}
	}
	pi.setActiveTools(newActive);
	return inline(`✓ Tools updated: ${changes.join(" ")} · Active: ${newActive.join(", ")}`);
}

function thinkingHandler(args: string, { pi }: CommandContext): CommandResult {
	if (!args) {
		return inline(`🧠 Thinking level: ${pi.getThinkingLevel()}`);
	}
	const validLevels = ["off", "minimal", "low", "medium", "high", "xhigh"];
	const level = args.toLowerCase();
	if (validLevels.includes(level)) {
		pi.setThinkingLevel(level as any);
		return inline(`✓ Thinking level set to: ${level}`);
	}
	return inline(`✗ Invalid level "${args}". Valid: ${validLevels.join(", ")}`);
}

function nameHandler(args: string, { pi }: CommandContext): CommandResult {
	if (!args) {
		const name = pi.getSessionName();
		return inline(name ? `📝 Session name: ${name}` : "📝 No session name set. Use /name <name> to set one.");
	}
	pi.setSessionName(args);
	return inline(`✓ Session name set to: ${args}`);
}

function contextHandler(_args: string, { ctx }: CommandContext): CommandResult {
	const usage = ctx.getContextUsage();
	if (!usage || usage.tokens === null) {
		return inline("📊 Context usage unavailable");
	}
	const pct = ((usage.tokens / usage.contextWindow) * 100).toFixed(1);
	const used = formatTokens(usage.tokens);
	const limit = `${(usage.contextWindow / 1000).toFixed(0)}k`;
	const filled = Math.round(Number(pct) / 5);
	const bar = "█".repeat(filled) + "░".repeat(20 - filled);
	return inline(`📊 Context: ${used} / ${limit} tokens (${pct}%) [${bar}]`);
}

function sessionHandler(_args: string, { ctx, pi }: CommandContext): CommandResult {
	const sessionFile = ctx.sessionManager.getSessionFile?.() ?? "ephemeral";
	const entries = ctx.sessionManager.getEntries();
	const branch = ctx.sessionManager.getBranch();
	const name = pi.getSessionName();
	const model = ctx.model;

	let userMsgs = 0, assistantMsgs = 0, toolCalls = 0;
	for (const entry of branch) {
		if (entry.type === "message") {
			if (entry.message?.role === "user") userMsgs++;
			else if (entry.message?.role === "assistant") assistantMsgs++;
			else if (entry.message?.role === "toolResult") toolCalls++;
		}
	}

	let duration = "";
	if (branch.length >= 2) {
		const first = branch[0]?.message?.timestamp || branch[0]?.timestamp;
		const last = branch[branch.length - 1]?.message?.timestamp || branch[branch.length - 1]?.timestamp;
		if (first && last) {
			const mins = Math.round((last - first) / 60000);
			duration = mins < 60 ? `${mins}m` : `${Math.floor(mins / 60)}h ${mins % 60}m`;
		}
	}

	let msg = `📁 Session: ${name ? `"${name}" · ` : ""}`;
	msg += `${entries.length} total entries · ${branch.length} in branch`;
	msg += ` · ${userMsgs} user · ${assistantMsgs} assistant · ${toolCalls} tool calls`;
	if (duration) msg += ` · Duration: ${duration}`;
	if (model) msg += ` · Model: ${model.provider}/${model.id}`;
	msg += ` · File: ${sessionFile}`;
	return inline(msg);
}

function commandsHandler(_args: string, { pi }: CommandContext): CommandResult {
	const registered = pi.getCommands();
	const grouped: Record<string, string[]> = {};
	for (const cmd of registered) {
		const src = cmd.source;
		if (!grouped[src]) grouped[src] = [];
		grouped[src].push(`/${cmd.name}${cmd.description ? ` - ${cmd.description}` : ""}`);
	}
	let msg = "📋 Available commands:";
	for (const [source, cmds] of Object.entries(grouped)) {
		msg += ` [${source}] ${cmds.join(", ")}`;
	}
	msg += " · Built-in: /new /fork /tree /model /reload /resume (use Esc to access)";
	return inline(msg);
}

function helpHandler(_args: string, _cmdCtx: CommandContext): CommandResult {
	const names = COMMANDS.map((c) => `/${c.name}`).join(" ");
	return inline(`${names} · Esc = access pi commands · /end = stop premium-usage mode`);
}

// ── Command Registry ───────────────────────────────────────────────────

/**
 * All commands in display order.
 * To add a new command: add an entry here and implement the handler above.
 */
export const COMMANDS: CommandDef[] = [
	{ name: "usage", description: "Show premium request usage stats", handler: usageHandler },
	{ name: "compact", description: "Compact conversation context", handler: compactHandler },
	{ name: "model", description: "Show current model or switch (e.g. /model sonnet)", handler: modelHandler },
	{ name: "tools", description: "Show active tools or toggle (e.g. /tools -read)", handler: toolsHandler },
	{ name: "thinking", description: "Show/set thinking level (off|minimal|low|medium|high|xhigh)", handler: thinkingHandler },
	{ name: "end", description: "End premium-usage session (next message costs a premium request)", handler: endHandler },
	{ name: "name", description: "Set session name (e.g. /name refactor auth)", handler: nameHandler },
	{ name: "context", description: "Show detailed context window usage", handler: contextHandler },
	{ name: "session", description: "Show session info (file, entries, branch depth)", handler: sessionHandler },
	{ name: "commands", description: "List all available slash commands", handler: commandsHandler },
	{ name: "help", description: "Show available commands", handler: helpHandler },
];

/** Lookup map for fast command dispatch. */
const COMMAND_MAP = new Map(COMMANDS.map((c) => [c.name, c]));

/** Slash command definitions for the editor autocomplete. */
export const SLASH_COMMANDS: SlashCommand[] = COMMANDS.map((c) => ({
	name: c.name,
	description: c.description,
}));

/**
 * Dispatch a slash command string (e.g. "/model sonnet").
 * Returns the command result, or undefined if the command is not recognized.
 */
export function dispatchCommand(input: string, cmdCtx: CommandContext): CommandResult | undefined {
	const name = input.slice(1).split(/\s+/)[0].toLowerCase();
	const args = input.slice(1 + name.length).trim();
	const cmd = COMMAND_MAP.get(name);
	if (!cmd) return undefined;
	return cmd.handler(args, cmdCtx);
}
