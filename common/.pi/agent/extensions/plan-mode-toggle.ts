import type {
	ExtensionAPI,
	ExtensionContext,
} from "@mariozechner/pi-coding-agent";

// Tools available in each mode
const PLAN_TOOLS = ["read", "bash", "grep", "find", "ls"];
const BUILD_TOOLS = ["read", "bash", "edit", "write", "grep", "find", "ls"];

// Bash commands blocked in plan mode
const BLOCKED_PATTERNS = [
	/\bsed\b/, /\btee\b/, /\becho\b.*[>]/, /\bcat\b.*[>]/,
	/[>]/, /[>]{2}/, /\bcp\b/, /\bmv\b/, /\brm\b/,
	/\bchmod\b/, /\bchown\b/, /\bmkdir\b/, /\btouch\b/,
	/\bgit\s+(add|commit|push|pull|merge|rebase|checkout\s+-b)\b/,
];

// System reminder messages injected into session history
const PLAN_ENTER_MESSAGE = `<system-reminder>
# Plan Mode

CRITICAL: Plan mode ON. Read-only.

FORBIDDEN:
- edit, write tools = removed
- sed, tee, echo >, cat >, cp, mv, rm, chmod, chown, mkdir, touch
- any bash with > or >>
- git add/commit/push/pull/merge/rebase

ALLOWED bash:
- ls, grep, find, cat file (no redirect), head, tail, less, pwd, wc
- read file only. no mutate.

## Rules

1. Blocked command = STOP. NO retry. NO "let me try again". NO thinking about workarounds.
2. User say "yes"/"ok"/"do it" = NOT auto-switch. Plan mode stay ON.
3. Need edits? Tell user: "Plan mode on. Hit tab for build mode." Then stop.
4. No exceptions. No assumptions.

Task: Think. Read. Search. Plan. Ask questions. No execute.
</system-reminder>`;

const PLAN_EXIT_MESSAGE = `<system-reminder>
Plan mode OFF. Build mode ON. Edit files. Run commands. Use all tools.
</system-reminder>`;

export default function planModeToggleExtension(pi: ExtensionAPI): void {
	let planModeEnabled = false;
	let lastMessagedState: boolean | null = null;

	function getLastMessagedStateFromSession(
		ctx: ExtensionContext,
	): boolean | null {
		const entries = ctx.sessionManager.getEntries();
		for (let i = entries.length - 1; i >= 0; i--) {
			const entry = entries[i];
			if (entry.type === "custom_message") {
				const customEntry = entry as { customType?: string };
				if (customEntry.customType === "plan-mode-enter") return true;
				if (customEntry.customType === "plan-mode-exit") return false;
			}
		}
		return null;
	}

	function updateStatus(ctx: ExtensionContext): void {
		if (planModeEnabled) {
			ctx.ui.setStatus("plan-mode", ctx.ui.theme.fg("warning", "⏸ plan"));
		} else {
			ctx.ui.setStatus("plan-mode", ctx.ui.theme.fg("success", "🔨 build"));
		}
	}

	function togglePlanMode(ctx: ExtensionContext): void {
		planModeEnabled = !planModeEnabled;

		if (planModeEnabled) {
			pi.setActiveTools(PLAN_TOOLS);
			ctx.ui.notify("Plan mode enabled. Read-only.", "warning");
		} else {
			pi.setActiveTools(BUILD_TOOLS);
			ctx.ui.notify("Build mode enabled. Full access.", "success");
		}

		updateStatus(ctx);
	}

	// Register tab shortcut
	pi.registerShortcut("tab", {
		description: "Toggle plan/build mode",
		handler: async (ctx) => {
			togglePlanMode(ctx);
		},
	});

	// Block file-mutating bash commands in plan mode
	pi.on("tool_call", async (event) => {
		if (!planModeEnabled || event.toolName !== "bash") return;

		const cmd = (event.input as { command?: string }).command?.toLowerCase() || "";

		for (const pattern of BLOCKED_PATTERNS) {
			if (pattern.test(cmd)) {
				return {
					block: true,
					reason: "Plan mode: file mutation blocked. Hit tab for build mode.",
				};
			}
		}
	});

	// Inject plan mode messages into LLM context when state changes
	pi.on("before_agent_start", async () => {
		if (planModeEnabled && lastMessagedState !== true) {
			lastMessagedState = true;
			return {
				message: {
					customType: "plan-mode-enter",
					content: PLAN_ENTER_MESSAGE,
					display: false,
				},
			};
		}

		if (!planModeEnabled && lastMessagedState === true) {
			lastMessagedState = false;
			return {
				message: {
					customType: "plan-mode-exit",
					content: PLAN_EXIT_MESSAGE,
					display: false,
				},
			};
		}
	});

	// Restore state on session start / resume / reload
	pi.on("session_start", async (_event, ctx) => {
		lastMessagedState = getLastMessagedStateFromSession(ctx);
		if (lastMessagedState === true) {
			planModeEnabled = true;
			pi.setActiveTools(PLAN_TOOLS);
		} else {
			planModeEnabled = false;
			pi.setActiveTools(BUILD_TOOLS);
		}
		updateStatus(ctx);
	});

	// Reset state on session switch
	pi.on("session_switch", async (_event, ctx) => {
		lastMessagedState = getLastMessagedStateFromSession(ctx);
		if (lastMessagedState === true) {
			planModeEnabled = true;
			pi.setActiveTools(PLAN_TOOLS);
		} else {
			planModeEnabled = false;
			pi.setActiveTools(BUILD_TOOLS);
		}
		updateStatus(ctx);
	});
}
