/**
 * Unit tests for the command registry.
 * Tests pure command dispatch logic with mocked pi/ctx.
 */

import { describe, it, expect, vi } from "vitest";
import { COMMANDS, SLASH_COMMANDS, dispatchCommand, type CommandContext } from "./commands.js";

// ── Mock factories ─────────────────────────────────────────────────────

function createMockPi(overrides: Partial<Record<string, any>> = {}) {
	return {
		getActiveTools: vi.fn(() => ["read", "bash", "edit", "write"]),
		getAllTools: vi.fn(() => [
			{ name: "read" }, { name: "bash" }, { name: "edit" },
			{ name: "write" }, { name: "end_turn" },
		]),
		setActiveTools: vi.fn(),
		getThinkingLevel: vi.fn(() => "medium"),
		setThinkingLevel: vi.fn(),
		getSessionName: vi.fn(() => null),
		setSessionName: vi.fn(),
		getCommands: vi.fn(() => [
			{ name: "usage", description: "Show usage", source: "premium-usage" },
		]),
		...overrides,
	} as any;
}

function createMockCtx(overrides: Partial<Record<string, any>> = {}) {
	return {
		getContextUsage: vi.fn(() => ({
			tokens: 50000,
			contextWindow: 200000,
			percent: 25.0,
		})),
		model: { provider: "anthropic", id: "claude-sonnet-4-20250514" },
		sessionManager: {
			getSessionFile: vi.fn(() => "/path/to/session.jsonl"),
			getEntries: vi.fn(() => new Array(20)),
			getBranch: vi.fn(() => [
				{ type: "message", message: { role: "user", timestamp: Date.now() - 300000 } },
				{ type: "message", message: { role: "assistant", timestamp: Date.now() - 290000 } },
				{ type: "message", message: { role: "toolResult", timestamp: Date.now() - 280000 } },
				{ type: "message", message: { role: "user", timestamp: Date.now() } },
			]),
			getLeafId: vi.fn(() => "leaf-123"),
		},
		...overrides,
	} as any;
}

function createCmdCtx(overrides: Partial<CommandContext> = {}): CommandContext {
	return {
		pi: createMockPi(),
		ctx: createMockCtx(),
		requestCount: 3,
		savedCount: 10,
		...overrides,
	};
}

// ── Registry ───────────────────────────────────────────────────────────

describe("Command Registry", () => {
	it("all commands have name, description, and handler", () => {
		for (const cmd of COMMANDS) {
			expect(cmd.name).toBeTruthy();
			expect(cmd.description).toBeTruthy();
			expect(typeof cmd.handler).toBe("function");
		}
	});

	it("SLASH_COMMANDS matches COMMANDS", () => {
		expect(SLASH_COMMANDS).toHaveLength(COMMANDS.length);
		for (let i = 0; i < COMMANDS.length; i++) {
			expect(SLASH_COMMANDS[i].name).toBe(COMMANDS[i].name);
			expect(SLASH_COMMANDS[i].description).toBe(COMMANDS[i].description);
		}
	});

	it("no duplicate command names", () => {
		const names = COMMANDS.map((c) => c.name);
		expect(new Set(names).size).toBe(names.length);
	});
});

// ── Dispatch ───────────────────────────────────────────────────────────

describe("dispatchCommand", () => {
	it("returns undefined for unknown commands", () => {
		expect(dispatchCommand("/nonexistent", createCmdCtx())).toBeUndefined();
	});

	it("dispatches known commands", () => {
		const result = dispatchCommand("/usage", createCmdCtx());
		expect(result).toBeDefined();
		expect(result!.type).toBe("inline");
	});

	it("passes arguments correctly", () => {
		const result = dispatchCommand("/name my-session", createCmdCtx());
		expect(result).toBeDefined();
		expect(result!.type).toBe("inline");
	});

	it("is case-insensitive for command names", () => {
		expect(dispatchCommand("/USAGE", createCmdCtx())).toBeDefined();
	});
});

// ── Inline commands ────────────────────────────────────────────────────

describe("/usage", () => {
	it("returns inline result with stats", () => {
		const result = dispatchCommand("/usage", createCmdCtx({ requestCount: 5, savedCount: 20 }));
		expect(result?.type).toBe("inline");
		const msg = (result as any).statusMessage;
		expect(msg).toContain("5");
		expect(msg).toContain("20");
	});

	it("includes context info when available", () => {
		const result = dispatchCommand("/usage", createCmdCtx());
		expect((result as any).statusMessage).toContain("Context:");
	});

	it("handles null tokens gracefully", () => {
		const cmdCtx = createCmdCtx();
		(cmdCtx.ctx.getContextUsage as any).mockReturnValue({ tokens: null, contextWindow: 200000, percent: null });
		const msg = (dispatchCommand("/usage", cmdCtx) as any).statusMessage;
		expect(msg).toContain("unknown");
	});
});

describe("/tools", () => {
	it("shows active/inactive tools when no args", () => {
		const msg = (dispatchCommand("/tools", createCmdCtx()) as any).statusMessage;
		expect(msg).toContain("read");
		expect(msg).toContain("end_turn"); // inactive
	});

	it("adds tools with + prefix", () => {
		const cmdCtx = createCmdCtx();
		dispatchCommand("/tools +grep", cmdCtx);
		const call = (cmdCtx.pi.setActiveTools as any).mock.calls[0][0];
		expect(call).toContain("grep");
	});

	it("removes tools with - prefix", () => {
		const cmdCtx = createCmdCtx();
		dispatchCommand("/tools -read", cmdCtx);
		const call = (cmdCtx.pi.setActiveTools as any).mock.calls[0][0];
		expect(call).not.toContain("read");
	});

	it("toggles tools without prefix", () => {
		const cmdCtx = createCmdCtx();
		dispatchCommand("/tools read", cmdCtx); // read is active → remove
		const call = (cmdCtx.pi.setActiveTools as any).mock.calls[0][0];
		expect(call).not.toContain("read");
	});
});

describe("/thinking", () => {
	it("shows current level when no args", () => {
		const msg = (dispatchCommand("/thinking", createCmdCtx()) as any).statusMessage;
		expect(msg).toContain("medium");
	});

	it("sets valid level", () => {
		const cmdCtx = createCmdCtx();
		dispatchCommand("/thinking high", cmdCtx);
		expect(cmdCtx.pi.setThinkingLevel).toHaveBeenCalledWith("high");
	});

	it("rejects invalid level", () => {
		const cmdCtx = createCmdCtx();
		const msg = (dispatchCommand("/thinking ultra", cmdCtx) as any).statusMessage;
		expect(cmdCtx.pi.setThinkingLevel).not.toHaveBeenCalled();
		expect(msg).toContain("Invalid");
	});
});

describe("/name", () => {
	it("shows current name", () => {
		const cmdCtx = createCmdCtx();
		(cmdCtx.pi.getSessionName as any).mockReturnValue("my-session");
		const msg = (dispatchCommand("/name", cmdCtx) as any).statusMessage;
		expect(msg).toContain("my-session");
	});

	it("shows hint when no name set", () => {
		const msg = (dispatchCommand("/name", createCmdCtx()) as any).statusMessage;
		expect(msg).toContain("No session name");
	});

	it("sets name", () => {
		const cmdCtx = createCmdCtx();
		dispatchCommand("/name refactor auth", cmdCtx);
		expect(cmdCtx.pi.setSessionName).toHaveBeenCalledWith("refactor auth");
	});
});

describe("/context", () => {
	it("shows bar when tokens available", () => {
		const msg = (dispatchCommand("/context", createCmdCtx()) as any).statusMessage;
		expect(msg).toContain("█");
		expect(msg).toContain("░");
	});

	it("handles null tokens", () => {
		const cmdCtx = createCmdCtx();
		(cmdCtx.ctx.getContextUsage as any).mockReturnValue({ tokens: null, contextWindow: 200000, percent: null });
		const msg = (dispatchCommand("/context", cmdCtx) as any).statusMessage;
		expect(msg).toContain("unavailable");
	});

	it("handles missing usage data", () => {
		const cmdCtx = createCmdCtx();
		(cmdCtx.ctx.getContextUsage as any).mockReturnValue(undefined);
		const msg = (dispatchCommand("/context", cmdCtx) as any).statusMessage;
		expect(msg).toContain("unavailable");
	});
});

describe("/session", () => {
	it("includes counts and model", () => {
		const msg = (dispatchCommand("/session", createCmdCtx()) as any).statusMessage;
		expect(msg).toContain("20 total entries");
		expect(msg).toContain("4 in branch");
		expect(msg).toContain("2 user");
		expect(msg).toContain("1 assistant");
		expect(msg).toContain("anthropic");
	});
});

describe("/commands", () => {
	it("lists registered commands", () => {
		const msg = (dispatchCommand("/commands", createCmdCtx()) as any).statusMessage;
		expect(msg).toContain("/usage");
		expect(msg).toContain("Built-in");
	});
});

describe("/help", () => {
	it("lists all command names", () => {
		const msg = (dispatchCommand("/help", createCmdCtx()) as any).statusMessage;
		for (const cmd of COMMANDS) {
			expect(msg).toContain(`/${cmd.name}`);
		}
	});
});

// ── Exit commands ──────────────────────────────────────────────────────

describe("/compact", () => {
	it("returns exit result", () => {
		expect(dispatchCommand("/compact", createCmdCtx())).toEqual({ type: "exit", command: "compact", args: undefined });
	});

	it("passes custom instructions", () => {
		expect(dispatchCommand("/compact keep tool results", createCmdCtx())).toEqual({
			type: "exit", command: "compact", args: "keep tool results",
		});
	});
});

describe("/end", () => {
	it("returns exit result", () => {
		expect(dispatchCommand("/end", createCmdCtx())).toEqual({ type: "exit", command: "end" });
	});
});

describe("/model", () => {
	it("returns model-select when no args", () => {
		expect(dispatchCommand("/model", createCmdCtx())).toEqual({ type: "exit", command: "model-select" });
	});

	it("returns model-switch with args", () => {
		expect(dispatchCommand("/model sonnet", createCmdCtx())).toEqual({ type: "exit", command: "model-switch", args: "sonnet" });
	});
});
