import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

// -------------------------------------------------------------------------
// Token formatting
// -------------------------------------------------------------------------

function fmtTok(n: number): string {
	if (n < 1000) return n.toString();
	if (n < 10000) return `${(n / 1000).toFixed(1)}k`;
	if (n < 1000000) return `${Math.round(n / 1000)}k`;
	if (n < 10000000) return `${(n / 1000000).toFixed(1)}M`;
	return `${Math.round(n / 1000000)}M`;
}

// -------------------------------------------------------------------------
// Stats aggregation
// -------------------------------------------------------------------------

interface TokenStats {
	input: number;
	output: number;
	cacheRead: number;
	cost: number;
}

function collectTokenStats(ctx: ExtensionContext): TokenStats {
	let input = 0;
	let output = 0;
	let cacheRead = 0;
	let cost = 0;

	for (const e of ctx.sessionManager.getEntries()) {
		if (e.type === "message" && e.message.role === "assistant") {
			const m = e.message as AssistantMessage;
			input += m.usage.input;
			output += m.usage.output;
			cacheRead += m.usage.cacheRead || 0;
			cost += m.usage.cost.total;
		}
	}

	return { input, output, cacheRead, cost };
}

// -------------------------------------------------------------------------
// Footer segments
// -------------------------------------------------------------------------

function buildLeftSegment(
	ctx: ExtensionContext,
	pi: ExtensionAPI,
	footerData: any,
): string {
	const parts: string[] = [];

	const branch = footerData.getGitBranch();
	if (branch) parts.push(`󰘬 ${branch}`);

	const modelId = ctx.model?.id || "no-model";
	parts.push(` ${modelId}`);

	const provider = (ctx.model as any)?.provider;
	if (provider) parts.push(` ${provider}`);

	const thinkingLevel = pi.getThinkingLevel();
	if (thinkingLevel && thinkingLevel !== "off") {
		parts.push(` ${thinkingLevel}`);
	}

	return parts.join("  ");
}

function buildRightSegment(
	stats: TokenStats,
	footerData: any,
): string {
	const parts: string[] = [];

	if (stats.input > 0) parts.push(` ${fmtTok(stats.input)}`);
	if (stats.output > 0) parts.push(` ${fmtTok(stats.output)}`);
	if (stats.cacheRead > 0) parts.push(` ${fmtTok(stats.cacheRead)}`);
	if (stats.cost > 0) parts.push(` ${stats.cost.toFixed(3)}`);

	const statuses = footerData.getExtensionStatuses();
	const allStatuses = Array.from(statuses.entries())
		.sort(([a], [b]) => a.localeCompare(b))
		.map(([, text]) => text)
		.join(" ");

	if (allStatuses) parts.push(allStatuses);

	return parts.join("  ");
}

// -------------------------------------------------------------------------
// Layout
// -------------------------------------------------------------------------

function layoutLine(
	left: string,
	right: string,
	width: number,
	theme: any,
): string {
	const margin = 2;
	const contentWidth = Math.max(0, width - margin * 2);
	const minPad = 2;

	const leftW = visibleWidth(left);
	const rightW = visibleWidth(right);

	let line: string;
	if (leftW + minPad + rightW <= contentWidth) {
		const pad = " ".repeat(contentWidth - leftW - rightW);
		line = left + pad + theme.fg("dim", right);
	} else if (rightW + minPad < contentWidth) {
		const maxLeft = contentWidth - rightW - minPad;
		const leftTrunc = truncateToWidth(left, maxLeft, "");
		const pad = " ".repeat(contentWidth - visibleWidth(leftTrunc) - rightW);
		line = leftTrunc + pad + theme.fg("dim", right);
	} else {
		line = truncateToWidth(left, contentWidth, "");
	}

	const finalLine = " ".repeat(margin) + line + " ".repeat(margin);
	return truncateToWidth(finalLine, width);
}

// -------------------------------------------------------------------------
// Footer renderer factory
// -------------------------------------------------------------------------

function createFooterRenderer(
	ctx: ExtensionContext,
	pi: ExtensionAPI,
) {
	return (tui: any, theme: any, footerData: any) => {
		const unsubBranch = footerData.onBranchChange(() => tui.requestRender());

		return {
			dispose: unsubBranch,
			invalidate() {},
			render(width: number): string[] {
				const stats = collectTokenStats(ctx);
				const left = buildLeftSegment(ctx, pi, footerData);
				const right = buildRightSegment(stats, footerData);
				const line = layoutLine(left, right, width, theme);
				return [line];
			},
		};
	};
}

// -------------------------------------------------------------------------
// Extension entry point
// -------------------------------------------------------------------------

export default function customFooterExtension(pi: ExtensionAPI): void {
	let enabled = true;

	function attachFooter(ctx: ExtensionContext): void {
		ctx.ui.setFooter(createFooterRenderer(ctx, pi));
	}

	pi.registerCommand("footer", {
		description: "Toggle custom compact footer",
		handler: async (_args, ctx) => {
			enabled = !enabled;
			if (enabled) {
				attachFooter(ctx);
				ctx.ui.notify("Custom footer enabled", "success");
			} else {
				ctx.ui.setFooter(undefined);
				ctx.ui.notify("Default footer restored", "info");
			}
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		if (enabled) attachFooter(ctx);
	});
}
