import type {
	ExtensionAPI,
	ExtensionContext,
} from "@mariozechner/pi-coding-agent";

// Tools available in each mode
const PLAN_TOOLS = ["read", "bash", "grep", "find", "ls"];
const BUILD_TOOLS = ["read", "bash", "edit", "write", "grep", "find", "ls"];

// Destructive bash commands blocked in plan mode
const DESTRUCTIVE_PATTERNS = [
	/\brm\b/i,
	/\brmdir\b/i,
	/\bmv\b/i,
	/\bcp\b/i,
	/\bmkdir\b/i,
	/\btouch\b/i,
	/\bchmod\b/i,
	/\bchown\b/i,
	/\bchgrp\b/i,
	/\bln\b/i,
	/\btee\b/i,
	/\btruncate\b/i,
	/\bdd\b/i,
	/\bshred\b/i,
	/(^|[^<])>(?!>)/,
	/>>/,
	/\bnpm\s+(install|uninstall|update|ci|link|publish)/i,
	/\byarn\s+(add|remove|install|publish)/i,
	/\bpnpm\s+(add|remove|install|publish)/i,
	/\bpip\s+(install|uninstall)/i,
	/\bapt(-get)?\s+(install|remove|purge|update|upgrade)/i,
	/\bbrew\s+(install|uninstall|upgrade)/i,
	/\bgit\s+(add|commit|push|pull|merge|rebase|reset|checkout|branch\s+-[dD]|stash|cherry-pick|revert|tag|init|clone)/i,
	/\bsudo\b/i,
	/\bsu\b/i,
	/\bkill\b/i,
	/\bpkill\b/i,
	/\bkillall\b/i,
	/\breboot\b/i,
	/\bshutdown\b/i,
	/\bsystemctl\s+(start|stop|restart|enable|disable)/i,
	/\bservice\s+\S+\s+(start|stop|restart)/i,
	/\b(vim?|nano|emacs|code|subl)\b/i,
];

// Safe read-only bash commands allowed in plan mode
const SAFE_PATTERNS = [
	/^\s*cat\b/,
	/^\s*head\b/,
	/^\s*tail\b/,
	/^\s*less\b/,
	/^\s*more\b/,
	/^\s*grep\b/,
	/^\s*find\b/,
	/^\s*ls\b/,
	/^\s*pwd\b/,
	/^\s*echo\b/,
	/^\s*printf\b/,
	/^\s*wc\b/,
	/^\s*sort\b/,
	/^\s*uniq\b/,
	/^\s*diff\b/,
	/^\s*file\b/,
	/^\s*stat\b/,
	/^\s*du\b/,
	/^\s*df\b/,
	/^\s*tree\b/,
	/^\s*which\b/,
	/^\s*whereis\b/,
	/^\s*type\b/,
	/^\s*env\b/,
	/^\s*printenv\b/,
	/^\s*uname\b/,
	/^\s*whoami\b/,
	/^\s*id\b/,
	/^\s*date\b/,
	/^\s*cal\b/,
	/^\s*uptime\b/,
	/^\s*ps\b/,
	/^\s*top\b/,
	/^\s*htop\b/,
	/^\s*free\b/,
	/^\s*git\s+(status|log|diff|show|branch|remote|config\s+--get)/i,
	/^\s*git\s+ls-/i,
	/^\s*npm\s+(list|ls|view|info|search|outdated|audit)/i,
	/^\s*yarn\s+(list|info|why|audit)/i,
	/^\s*node\s+--version/i,
	/^\s*python\s+--version/i,
	/^\s*curl\s/i,
	/^\s*wget\s+-O\s*-/i,
	/^\s*jq\b/,
	/^\s*sed\s+-n/i,
	/^\s*awk\b/,
	/^\s*rg\b/,
	/^\s*fd\b/,
	/^\s*bat\b/,
	/^\s*eza\b/,
];

function isSafeCommand(command: string): boolean {
	const isDestructive = DESTRUCTIVE_PATTERNS.some((p) => p.test(command));
	const isSafe = SAFE_PATTERNS.some((p) => p.test(command));
	return !isDestructive && isSafe;
}

// System reminder messages injected into session history
const PLAN_ENTER_MESSAGE = `<system-reminder>
# Plan Mode

CRITICAL: Plan mode ON. Read-only.

FORBIDDEN:
- edit, write tools = removed
- file mutation: rm, mv, cp, mkdir, touch, chmod, chown, chgrp, ln, tee, truncate, dd, shred
- redirects: any bash with > or >>
- git write: add, commit, push, pull, merge, rebase, reset, checkout, stash, cherry-pick
- package managers: npm/yarn/pnpm/pip/apt/brew install, update, remove
- system: sudo, kill, reboot, shutdown, systemctl start/stop/restart
- editors: vim, nano, emacs, code

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

	// Block non-safe bash commands in plan mode
	pi.on("tool_call", async (event) => {
		if (!planModeEnabled || event.toolName !== "bash") return;

		const cmd = (event.input as { command?: string }).command || "";

		if (!isSafeCommand(cmd)) {
			return {
				block: true,
				reason:
					"Plan mode: command blocked (not allowlisted). Hit tab for build mode.",
			};
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
