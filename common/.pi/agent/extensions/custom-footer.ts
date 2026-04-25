import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

/**
 * Format token counts matching pi's built-in footer style
 */
function fmtTok(n: number): string {
	if (n < 1000) return n.toString();
	if (n < 10000) return `${(n / 1000).toFixed(1)}k`;
	if (n < 1000000) return `${Math.round(n / 1000)}k`;
	if (n < 10000000) return `${(n / 1000000).toFixed(1)}M`;
	return `${Math.round(n / 1000000)}M`;
}

function shortModelName(id: string): string {
	return id
		.replace(/^(claude-3-|gpt-4-|gpt-3\.5-)/, "")
		.replace(/-\d{8}$/, "")
		.replace(/-latest$/, "")
		.replace(/-\d{4}$/, "");
}

export default function customFooterExtension(pi: ExtensionAPI): void {
	let enabled = true;

	function setCustomFooter(ctx: ExtensionContext): void {
		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsubBranch = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose: unsubBranch,
				invalidate() {},
				render(width: number): string[] {
					return renderFooter(ctx, theme, footerData, width);
				},
			};
		});
	}

	function renderFooter(
		ctx: ExtensionContext,
		theme: any,
		footerData: any,
		width: number,
	): string[] {
		// Cumulative token stats from ALL session entries (matches built-in footer)
		let totalInput = 0;
		let totalOutput = 0;
		let totalCacheRead = 0;
		let totalCost = 0;

		for (const e of ctx.sessionManager.getEntries()) {
			if (e.type === "message" && e.message.role === "assistant") {
				const m = e.message as AssistantMessage;
				totalInput += m.usage.input;
				totalOutput += m.usage.output;
				totalCacheRead += m.usage.cacheRead || 0;
				totalCost += m.usage.cost.total;
			}
		}

		// ALL extension statuses (mode-toggle, plannotator, etc.)
		const statuses = footerData.getExtensionStatuses();
		const modeBadge = statuses.get("mode") || "";

		// Other statuses (plannotator, etc.) — sorted alphabetically like pi's built-in
		const otherStatuses = Array.from(statuses.entries())
			.filter(([key]) => key !== "mode")
			.sort(([a], [b]) => a.localeCompare(b))
			.map(([, text]) => text)
			.join("  ");

		// Model info with provider (matches pi's format)
		const modelId = ctx.model?.id || "no-model";
		const modelShort = shortModelName(modelId);
		const provider = (ctx.model as any)?.provider;

		let modelStr = provider ? `${modelShort} (${provider})` : modelShort;

		// Thinking level (if model supports reasoning)
		const thinkingLevel = pi.getThinkingLevel();
		if (thinkingLevel && thinkingLevel !== "off") {
			modelStr += ` • ${thinkingLevel}`;
		}

		// Git branch
		const branch = footerData.getGitBranch();

		// --- LEFT: identity ---
		const leftParts: string[] = [];
		if (modeBadge) leftParts.push(modeBadge);
		if (branch) leftParts.push(`(${branch})`);
		leftParts.push(modelStr);

		const leftStr = leftParts.join("  ");

		// --- RIGHT: stats + other statuses ---
		const rightParts: string[] = [];

		// Token stats
		if (totalInput > 0) rightParts.push(`↑${fmtTok(totalInput)}`);
		if (totalOutput > 0) rightParts.push(`↓${fmtTok(totalOutput)}`);
		if (totalCacheRead > 0) rightParts.push(`R${fmtTok(totalCacheRead)}`);
		if (totalCost > 0) rightParts.push(`$${totalCost.toFixed(3)}`);

		// Other extension statuses (plannotator, etc.)
		if (otherStatuses) {
			rightParts.push(otherStatuses);
		}

		const rightStr = rightParts.join("  ");

		// Assemble with right-align
		const leftW = visibleWidth(leftStr);
		const rightW = visibleWidth(rightStr);
		const minPad = 2;

		let line: string;
		if (leftW + minPad + rightW <= width) {
			const pad = " ".repeat(width - leftW - rightW);
			line = leftStr + pad + theme.fg("dim", rightStr);
		} else if (rightW + minPad < width) {
			// Truncate left to fit right side
			const maxLeft = width - rightW - minPad;
			const leftTrunc = truncateToWidth(leftStr, maxLeft, "");
			const pad = " ".repeat(width - visibleWidth(leftTrunc) - rightW);
			line = leftTrunc + pad + theme.fg("dim", rightStr);
		} else {
			// Not enough room for right side, just left
			line = truncateToWidth(leftStr, width, "");
		}

		return [truncateToWidth(line, width)];
	}

	pi.registerCommand("footer", {
		description: "Toggle custom compact footer",
		handler: async (_args, ctx) => {
			enabled = !enabled;

			if (enabled) {
				setCustomFooter(ctx);
				ctx.ui.notify("Custom footer enabled", "success");
			} else {
				ctx.ui.setFooter(undefined);
				ctx.ui.notify("Default footer restored", "info");
			}
		},
	});

	// Auto-enable on session start
	pi.on("session_start", async (_event, ctx) => {
		if (enabled) {
			setCustomFooter(ctx);
		}
	});
}
