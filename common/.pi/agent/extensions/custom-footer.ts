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
	let enabled = false;

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

		// Mode badge from extension statuses (e.g. mode-toggle.ts)
		const statuses = footerData.getExtensionStatuses();
		const modeBadge = statuses.get("mode") || "";

		// Model info with provider (matches pi's format)
		const modelId = ctx.model?.id || "no-model";
		const modelShort = shortModelName(modelId);
		const provider = (ctx.model as any)?.provider;

		// Pi shows provider in parens before model when multiple providers available
		// For simplicity, always show: model (provider)
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

		// --- RIGHT: stats (same format as pi default) ---
		const statParts: string[] = [];
		if (totalInput > 0) statParts.push(`↑${fmtTok(totalInput)}`);
		if (totalOutput > 0) statParts.push(`↓${fmtTok(totalOutput)}`);
		if (totalCacheRead > 0) statParts.push(`R${fmtTok(totalCacheRead)}`);
		if (totalCost > 0) statParts.push(`$${totalCost.toFixed(3)}`);

		const statsStr = statParts.join(" ");

		// Assemble with right-align
		const leftW = visibleWidth(leftStr);
		const statsW = visibleWidth(statsStr);
		const minPad = 2;

		let line: string;
		if (leftW + minPad + statsW <= width) {
			const pad = " ".repeat(width - leftW - statsW);
			line = leftStr + pad + theme.fg("dim", statsStr);
		} else if (statsW + minPad < width) {
			// Truncate left to fit stats
			const maxLeft = width - statsW - minPad;
			const leftTrunc = truncateToWidth(leftStr, maxLeft, "");
			const pad = " ".repeat(width - visibleWidth(leftTrunc) - statsW);
			line = leftTrunc + pad + theme.fg("dim", statsStr);
		} else {
			// No room for stats, just left
			line = truncateToWidth(leftStr, width, "");
		}

		return [truncateToWidth(line, width)];
	}

	pi.registerCommand("footer", {
		description: "Toggle custom compact footer",
		handler: async (_args, ctx) => {
			enabled = !enabled;

			if (enabled) {
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
				ctx.ui.notify("Custom footer enabled", "success");
			} else {
				ctx.ui.setFooter(undefined);
				ctx.ui.notify("Default footer restored", "info");
			}
		},
	});
}
