import type {
	ExtensionAPI,
	ExtensionContext,
} from "@mariozechner/pi-coding-agent";

// Tools available in each mode
const READ_TOOLS = ["read", "bash", "grep", "find", "ls"];
const WRITE_TOOLS = ["read", "bash", "edit", "write", "grep", "find", "ls"];

// Destructive bash commands blocked in read mode
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

// Safe read-only bash commands allowed in read mode
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
const READ_ENTER_MESSAGE = `<system-reminder>
# READ MODE — READ ONLY

## BLOCKED COMMAND = STOP. NO EXCEPTIONS.
- No retry. No alternative approach. No "let me try..."
- No bash workarounds (python3, sed, printf, cat>, tee, etc.)
- No asking user "do you want me to..."

## INSTEAD
Tell user: "Read mode on. Hit tab for write mode." Then **STOP**.

---

## FORBIDDEN
- edit, write tools = removed
- file mutation: rm, mv, cp, mkdir, touch, chmod, chown, chgrp, ln, tee, truncate, dd, shred
- redirects: any bash with > or >>
- git write: add, commit, push, pull, merge, rebase, reset, checkout, stash, cherry-pick
- package managers: npm/yarn/pnpm/pip/apt/brew install, update, remove
- system: sudo, kill, reboot, shutdown, systemctl start/stop/restart
- editors: vim, nano, emacs, code

## ALLOWED
- ls, grep, find, cat file (no redirect), head, tail, less, pwd, wc
- read file only. no mutate.

User say "yes"/"ok"/"do it" = NOT auto-switch.
Need edits? Tell user: "Read mode on. Hit tab for write mode." Then stop.
</system-reminder>`;

const WRITE_ENTER_MESSAGE = `<system-reminder>
Read mode OFF. Write mode ON. Edit files. Run commands. Use all tools.
</system-reminder>`;

export default function modeToggleExtension(pi: ExtensionAPI): void {
	let readModeEnabled = true;
	let lastMessagedState: boolean | null = null;

	function getLastMessagedStateFromSession(
		ctx: ExtensionContext,
	): boolean | null {
		const entries = ctx.sessionManager.getEntries();
		for (let i = entries.length - 1; i >= 0; i--) {
			const entry = entries[i];
			if (entry.type === "custom_message") {
				const customEntry = entry as { customType?: string };
				if (customEntry.customType === "mode-enter:read") return true;
				if (customEntry.customType === "mode-enter:write") return false;
			}
		}
		return null;
	}

	function updateStatus(ctx: ExtensionContext): void {
		if (readModeEnabled) {
			ctx.ui.setStatus("mode", ctx.ui.theme.fg("warning", "READ"));
		} else {
			ctx.ui.setStatus("mode", ctx.ui.theme.fg("success", "WRITE"));
		}
	}

	function toggleReadWriteMode(ctx: ExtensionContext): void {
		readModeEnabled = !readModeEnabled;

		if (readModeEnabled) {
			pi.setActiveTools(READ_TOOLS);
		} else {
			pi.setActiveTools(WRITE_TOOLS);
		}

		updateStatus(ctx);
	}

	// Register tab shortcut
	pi.registerShortcut("tab", {
		description: "Toggle read/write mode",
		handler: async (ctx) => {
			toggleReadWriteMode(ctx);
		},
	});

	const BLOCK_REASON =
		"BLOCKED — read mode active. STOP. Do not retry with a different command. Do not try edit, write, bash, or any other tool to modify files. ALL modifications are disabled. Tell user: \"Read mode is on. Press tab for write mode.\" Then STOP. No further tool calls.";

	// Block write tools and non-safe bash commands in read mode
	pi.on("tool_call", async (event, ctx) => {
		if (!readModeEnabled) return;

		// Block edit/write even if LLM hallucinates them
		if (event.toolName === "edit" || event.toolName === "write") {
			ctx.ui.notify("Command blocked: read mode is active", "warning");
			return { block: true, reason: BLOCK_REASON };
		}

		if (event.toolName === "bash") {
			const cmd = (event.input as { command?: string }).command || "";
			if (!isSafeCommand(cmd)) {
				ctx.ui.notify("Command blocked: read mode is active", "warning");
				return { block: true, reason: BLOCK_REASON };
			}
		}
	});

	// Inject read mode messages into LLM context when state changes
	pi.on("before_agent_start", async () => {
		if (readModeEnabled && lastMessagedState !== true) {
			lastMessagedState = true;
			return {
				message: {
					customType: "mode-enter:read",
					content: READ_ENTER_MESSAGE,
					display: false,
				},
			};
		}

		if (!readModeEnabled && lastMessagedState === true) {
			lastMessagedState = false;
			return {
				message: {
					customType: "mode-enter:write",
					content: WRITE_ENTER_MESSAGE,
					display: false,
				},
			};
		}
	});

	// Restore state on session start / resume / reload
	pi.on("session_start", async (_event, ctx) => {
		lastMessagedState = getLastMessagedStateFromSession(ctx);
		if (lastMessagedState === true) {
			readModeEnabled = true;
			pi.setActiveTools(READ_TOOLS);
		} else if (lastMessagedState === false) {
			readModeEnabled = false;
			pi.setActiveTools(WRITE_TOOLS);
		} else {
			// null = new session, default to READ mode
			readModeEnabled = true;
			pi.setActiveTools(READ_TOOLS);
			lastMessagedState = true;
		}
		updateStatus(ctx);
	});

	// Reset state on session switch
	pi.on("session_switch", async (_event, ctx) => {
		lastMessagedState = getLastMessagedStateFromSession(ctx);
		if (lastMessagedState === true) {
			readModeEnabled = true;
			pi.setActiveTools(READ_TOOLS);
		} else if (lastMessagedState === false) {
			readModeEnabled = false;
			pi.setActiveTools(WRITE_TOOLS);
		} else {
			// null = new session, default to READ mode
			readModeEnabled = true;
			pi.setActiveTools(READ_TOOLS);
			lastMessagedState = true;
		}
		updateStatus(ctx);
	});
}
