import type {
	ExtensionAPI,
	ExtensionContext,
} from "@mariozechner/pi-coding-agent";
import { completeSimple } from "@mariozechner/pi-ai";

// Tools available in each mode
const READ_TOOLS = ["read", "bash", "grep", "find", "ls"];
const WRITE_TOOLS = ["read", "bash", "edit", "write", "grep", "find", "ls"];

// ── Bash command safety ────────────────────────────────────────────────

// Safe commands allowed in read mode without review
const SAFE_PATTERNS = [
	/^\s*cat\b/,
	/^\s*ls\b/,
	/^\s*grep\b/,
	/^\s*find\b/,
	/^\s*head\b/,
	/^\s*tail\b/,
	/^\s*less\b/,
	/^\s*more\b/,
	/^\s*wc\b/,
	/^\s*sort\b/,
	/^\s*uniq\b/,
	/^\s*diff\b/,
	/^\s*pwd\b/,
	/^\s*echo\b/,
	/^\s*printf\b/,
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

// Always blocked — no exceptions (not even in /tmp)
const ALWAYS_BLOCKED = [
	/[;&`\n]/, // shell metacharacters
	/>{1,2}/, // redirects
	/\brm\b/i,
	/\brmdir\b/i,
	/\bchmod\b/i,
	/\bchown\b/i,
	/\bchgrp\b/i,
	/\btee\b/i,
	/\btruncate\b/i,
	/\bdd\b/i,
	/\bshred\b/i,
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

// Allowed in /tmp without AI review
const TMP_ALLOWED = [
	/\bcp\b/i,
	/\bmkdir\b/i,
	/\btouch\b/i,
	/\bln\b/i,
	/\bgit\s+clone\b/i,
	/\bgit\s+init\b/i,
	/\bnpm\s+(install|ci)\b/i,
	/\byarn\s+(install|add)\b/i,
	/\bpnpm\s+(install|add)\b/i,
	/\bpip\s+install\b/i,
	/\bcurl\b/i,
	/\bwget\b/i,
	/\bapt(-get)?\s+(install|update)\b/i,
	/\bbrew\s+(install|upgrade)\b/i,
];

function isOperatingInTmp(command: string): boolean {
	return /\b(\/tmp|\/var\/tmp|\$TMPDIR)\b/.test(command);
}

function isBlocked(command: string): { blocked: boolean; reason?: string } {
	for (const pattern of ALWAYS_BLOCKED) {
		if (pattern.test(command)) {
			return {
				blocked: true,
				reason: "Destructive construct blocked in read mode",
			};
		}
	}
	return { blocked: false };
}

function isWhitelisted(command: string): boolean {
	const trimmed = command
		.trim()
		.replace(/\\\n\s*/g, "")
		.replace(/\n\s*/g, " ");
	return SAFE_PATTERNS.some((p) => p.test(trimmed));
}

function isTmpAllowed(command: string): boolean {
	if (!isOperatingInTmp(command)) return false;
	return TMP_ALLOWED.some((p) => p.test(command));
}

function getBashOverride(entries: any[], command: string): boolean {
	for (const entry of entries) {
		if (entry.type === "custom" && entry.customType === "mode-bash-override") {
			if (entry.data?.command === command) return true;
		}
	}
	return false;
}

async function reviewWithAI(
	command: string,
	ctx: ExtensionContext,
): Promise<{ allow: boolean; reason?: string }> {
	try {
		const currentModel = ctx.model;
		if (!currentModel) {
			return { allow: false, reason: "No model available for AI review" };
		}

		const authResult =
			await ctx.modelRegistry.getApiKeyAndHeaders(currentModel);
		if (!authResult.ok) {
			return { allow: false, reason: "Auth failed for AI review" };
		}

		const response = await completeSimple(
			currentModel,
			{
				messages: [
					{
						role: "user",
						content: [
							{
								type: "text",
								text:
									"Is this bash command EXPLORATORY (read-only, safe) or MUTATING (writes, deletes, or changes state)?\n\n" +
									`$ ${command}\n\nRespond with a single word: EXPLORATORY or MUTATING`,
							},
						],
						timestamp: Date.now(),
					},
				],
			},
			{
				apiKey: authResult.apiKey,
				headers: authResult.headers,
				maxTokens: 256,
			},
		);

		const text = response.content
			.filter((c) => c.type === "text")
			.map((c) => c.text)
			.join(" ")
			.toLowerCase();

		if (text.includes("mutating")) {
			return { allow: false, reason: "AI review: command appears mutating" };
		}

		return { allow: true };
	} catch (error: any) {
		console.error("Mode-toggle AI review failed:", error);
		return { allow: false, reason: `AI review failed: ${error.message}` };
	}
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
- file mutation: rm, chmod, chown, chgrp, ln, tee, truncate, dd, shred
- redirects: any bash with > or >>
- system: sudo, kill, reboot, shutdown, systemctl start/stop/restart
- editors: vim, nano, emacs, code

## ALLOWED
- ls, grep, find, cat, head, tail, less, pwd, wc, git status/log/diff
- /tmp operations: git clone, npm install, curl, wget, etc.
- Unknown commands: AI-reviewed. If blocked, you may be asked to confirm.

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
		'BLOCKED — read mode active. STOP. Do not retry with a different command. Do not try edit, write, bash, or any other tool to modify files. ALL modifications are disabled. Tell user: "Read mode is on. Press tab for write mode." Then STOP. No further tool calls.';

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

			// Check for user override from earlier in session
			const entries = ctx.sessionManager.getEntries();
			if (getBashOverride(entries, cmd)) return;

			// Always-blocked constructs (redirects, rm, sudo, editors)
			const blocked = isBlocked(cmd);
			if (blocked.blocked) {
				ctx.ui.notify("Command blocked: read mode is active", "warning");
				return { block: true, reason: blocked.reason };
			}

			// Whitelisted safe commands
			if (isWhitelisted(cmd)) return;

			// /tmp exception
			if (isTmpAllowed(cmd)) return;

			// AI review for unknown commands
			const review = await reviewWithAI(cmd, ctx);
			if (review.allow) return;

			// Ask user for override
			const allowed = await ctx.ui.confirm(
				"Read mode: command blocked",
				`${review.reason}\n\n  $ ${cmd}\n\nAllow anyway?`,
			);

			if (allowed) {
				pi.appendEntry("mode-bash-override", {
					command: cmd,
					timestamp: Date.now(),
				});
				return;
			}

			ctx.ui.notify("Command blocked: read mode is active", "warning");
			return {
				block: true,
				reason: review.reason || "Command blocked by AI review",
			};
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
