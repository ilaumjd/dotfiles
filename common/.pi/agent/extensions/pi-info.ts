/**
 * Pi Info Extension
 *
 * One-command overview of everything: pi version, tools,
 * extensions, models, commands, context usage, etc.
 *
 * Usage:
 *   /info                → compact summary popup
 *   /info all            → full overview
 *   /info tools          → active + all tools
 *   /info models         → available models
 *   /info extensions     → loaded extensions
 *   /info commands       → slash commands
 *   /info context        → context usage stats
 */

import type { ExtensionAPI, ExtensionCommandContext } from "@mariozechner/pi-coding-agent";
import { existsSync, readFileSync, readdirSync, statSync } from "fs";
import { join } from "path";
import { homedir } from "os";

// -------------------------------------------------------------------------
// Settings reader
// -------------------------------------------------------------------------

interface PiSettings {
	lastChangelogVersion?: string;
	packages?: string[];
	theme?: string;
}

function loadSettings(): PiSettings {
	const path = join(homedir(), ".pi", "agent", "settings.json");
	try {
		return JSON.parse(readFileSync(path, "utf-8")) as PiSettings;
	} catch {
		return {};
	}
}

// -------------------------------------------------------------------------
// Extension scanner (mirrors pi loader discovery rules)
// -------------------------------------------------------------------------

function isExtensionFile(name: string): boolean {
	return name.endsWith(".ts") || name.endsWith(".js");
}

function hasEntryPoint(dir: string): boolean {
	return (
		existsSync(join(dir, "package.json")) ||
		existsSync(join(dir, "index.ts")) ||
		existsSync(join(dir, "index.js"))
	);
}

function scanExtDir(dir: string): string[] {
	if (!existsSync(dir)) return [];
	const found: string[] = [];
	try {
		for (const entry of readdirSync(dir, { withFileTypes: true })) {
			if (entry.isFile() && isExtensionFile(entry.name)) {
				found.push(entry.name);
			} else if ((entry.isDirectory() || entry.isSymbolicLink()) && hasEntryPoint(join(dir, entry.name))) {
				found.push(`${entry.name}/`);
			}
		}
	} catch {
		// ignore unreadable
	}
	return found.sort();
}

// -------------------------------------------------------------------------
// Compact summary (for popup notification)
// -------------------------------------------------------------------------

function buildCompactSummary(pi: ExtensionAPI, ctx: ExtensionCommandContext): string {
	const theme = ctx.ui.theme;
	const settings = loadSettings();
	const version = settings.lastChangelogVersion ?? "unknown";

	const usage = ctx.getContextUsage();
	const ctxLine = usage
		? `${usage.tokens?.toLocaleString() ?? "?"} / ${usage.contextWindow.toLocaleString()} (${usage.percent?.toFixed(1) ?? "?"}%)`
		: "n/a";

	const activeTools = pi.getActiveTools().length;
	const totalTools = pi.getAllTools().length;

	const globalExts = scanExtDir(join(homedir(), ".pi", "agent", "extensions")).length;
	const localExts = scanExtDir(join(ctx.cwd, ".pi", "extensions")).length;
	const npmPkgs = (settings.packages ?? []).length;

	const lines = [
		theme.bold("Pi Info"),
		"",
		`${theme.fg("dim", "Version:")}  ${theme.fg("accent", version)}`,
		`${theme.fg("dim", "Context:")}   ${ctxLine}`,
		`${theme.fg("dim", "Tools:")}     ${activeTools} active / ${totalTools} total`,
		`${theme.fg("dim", "Exts:")}      ${globalExts} global + ${localExts} local + ${npmPkgs} npm`,
	];

	return lines.join("\n");
}

// -------------------------------------------------------------------------
// Full selector builder
// -------------------------------------------------------------------------

function buildFullItems(pi: ExtensionAPI, ctx: ExtensionCommandContext): string[] {
	const theme = ctx.ui.theme;
	const items: string[] = [];
	const settings = loadSettings();

	// --- Pi Version ---
	items.push(theme.bold("━━━ Pi Version ━━━"));
	items.push(`Version: ${settings.lastChangelogVersion ?? "unknown"}`);
	items.push("");

	// --- Context Usage ---
	items.push(theme.bold("━━━ Context Usage ━━━"));
	const u = ctx.getContextUsage();
	if (u) {
		items.push(`Tokens: ${u.tokens?.toLocaleString() ?? "unknown"}`);
		items.push(`Window: ${u.contextWindow.toLocaleString()}`);
		items.push(`Percent: ${u.percent?.toFixed(2) ?? "unknown"}%`);
	} else {
		items.push("n/a");
	}
	items.push("");

	// --- Tools ---
	const allTools = pi.getAllTools();
	const active = new Set(pi.getActiveTools().map((t) => t.toLowerCase()));
	items.push(theme.bold(`━━━ Tools (${pi.getActiveTools().length} active / ${allTools.length} total) ━━━`));
	for (const t of allTools) {
		const on = active.has(t.name.toLowerCase()) ? "●" : "○";
		items.push(`${on} ${t.name} — ${t.description.slice(0, 60)}${t.description.length > 60 ? "…" : ""} [${t.sourceInfo.source}]`);
	}
	items.push("");

	// --- Commands ---
	const cmds = pi.getCommands();
	items.push(theme.bold(`━━━ Commands (${cmds.length}) ━━━`));
	for (const c of cmds) {
		const desc = c.description ? ` — ${c.description}` : "";
		items.push(`/${c.name}${desc}`);
	}
	items.push("");

	// --- Models ---
	const availableModels = ctx.modelRegistry.getAvailable();
	items.push(theme.bold(`━━━ Models (${availableModels.length} available) ━━━`));
	const byProvider = new Map<string, typeof availableModels>();
	for (const model of availableModels) {
		const list = byProvider.get(model.provider) ?? [];
		list.push(model);
		byProvider.set(model.provider, list);
	}
	for (const [provider, models] of [...byProvider.entries()].sort((a, b) => a[0].localeCompare(b[0]))) {
		items.push(`${theme.fg("accent", provider)} (${models.length}): ${models.sort((a, b) => a.id.localeCompare(b.id)).map(m => m.id).join(", ")}`);
	}
	items.push("");

	// --- Extensions ---
	items.push(theme.bold("━━━ Extensions ━━━"));
	const globalList = scanExtDir(join(homedir(), ".pi", "agent", "extensions"));
	const localList = scanExtDir(join(ctx.cwd, ".pi", "extensions"));
	const pkgs = settings.packages ?? [];
	items.push(`Global (${globalList.length}): ${globalList.join(", ") || "none"}`);
	items.push(`Local  (${localList.length}): ${localList.join(", ") || "none"}`);
	items.push(`NPM    (${pkgs.length}): ${pkgs.join(", ") || "none"}`);
	items.push("");

	return items;
}

// -------------------------------------------------------------------------
// Per-section builders
// -------------------------------------------------------------------------

function buildToolsItems(pi: ExtensionAPI, ctx: ExtensionCommandContext): string[] {
	const allTools = pi.getAllTools();
	const active = new Set(pi.getActiveTools().map((t) => t.toLowerCase()));
	const items: string[] = [];
	items.push(`Active: ${pi.getActiveTools().length} / Total: ${allTools.length}`);
	items.push("");
	for (const t of allTools) {
		const on = active.has(t.name.toLowerCase()) ? "●" : "○";
		items.push(`${on} ${t.name}`);
		items.push(`   ${t.description}`);
		items.push(`   [source: ${t.sourceInfo.source}]`);
	}
	return items;
}

function buildModelsItems(ctx: ExtensionCommandContext): string[] {
	const items: string[] = [];
	const availableModels = ctx.modelRegistry.getAvailable();
	const byProvider = new Map<string, typeof availableModels>();
	for (const model of availableModels) {
		const list = byProvider.get(model.provider) ?? [];
		list.push(model);
		byProvider.set(model.provider, list);
	}
	if (byProvider.size === 0) {
		items.push("No models available (no API keys configured)");
		return items;
	}
	for (const [provider, models] of [...byProvider.entries()].sort((a, b) => a[0].localeCompare(b[0]))) {
		items.push(`${provider} (${models.length}): ${models.sort((a, b) => a.id.localeCompare(b.id)).map(m => m.id).join(", ")}`);
		items.push("");
	}
	return items;
}

function buildExtensionsItems(ctx: ExtensionCommandContext): string[] {
	const settings = loadSettings();
	const globalList = scanExtDir(join(homedir(), ".pi", "agent", "extensions"));
	const localList = scanExtDir(join(ctx.cwd, ".pi", "extensions"));
	const pkgs = settings.packages ?? [];
	return [
		`Global (${globalList.length}): ${globalList.join(", ") || "none"}`,
		"",
		`Local  (${localList.length}): ${localList.join(", ") || "none"}`,
		"",
		`NPM    (${pkgs.length}): ${pkgs.join(", ") || "none"}`,
	];
}

function buildCommandsItems(pi: ExtensionAPI): string[] {
	return pi.getCommands().map((c) => {
		const desc = c.description ? ` — ${c.description}` : "";
		return `/${c.name}${desc}`;
	});
}

function buildContextItems(ctx: ExtensionCommandContext): string[] {
	const u = ctx.getContextUsage();
	if (!u) return ["Context usage not available"];
	return [
		`Tokens:  ${u.tokens?.toLocaleString() ?? "unknown"}`,
		`Window:  ${u.contextWindow.toLocaleString()}`,
		`Percent: ${u.percent?.toFixed(2) ?? "unknown"}%`,
	];
}

// -------------------------------------------------------------------------
// Section dispatcher
// -------------------------------------------------------------------------

function buildSectionItems(
	pi: ExtensionAPI,
	ctx: ExtensionCommandContext,
	section: string,
): string[] {
	switch (section) {
		case "tools":
			return buildToolsItems(pi, ctx);
		case "models":
			return buildModelsItems(ctx);
		case "extensions":
			return buildExtensionsItems(ctx);
		case "commands":
			return buildCommandsItems(pi);
		case "context":
			return buildContextItems(ctx);
		default:
			return [];
	}
}

// -------------------------------------------------------------------------
// Entry point
// -------------------------------------------------------------------------

export default function piInfoExtension(pi: ExtensionAPI): void {
	pi.registerCommand("info", {
		description:
			"Show pi system info (version, tools, models, extensions, commands, context)",
		getArgumentCompletions: (prefix) => {
			const opts = [
				"summary",
				"all",
				"tools",
				"models",
				"extensions",
				"commands",
				"context",
			];
			const filtered = opts.filter((o) => o.startsWith(prefix));
			return filtered.length > 0 ? filtered.map((v) => ({ value: v, label: v })) : null;
		},
		handler: async (rawArgs, ctx: ExtensionCommandContext) => {
			const args = (typeof rawArgs === "string" ? rawArgs.trim() : "").toLowerCase();

			if (!args || args === "summary") {
				ctx.ui.notify(buildCompactSummary(pi, ctx), "info");
				return;
			}

			if (args === "all" || args === "full") {
				const items = buildFullItems(pi, ctx);
				ctx.ui.notify(items.join("\n"), "info");
				return;
			}

			const items = buildSectionItems(pi, ctx, args);
			if (items.length > 0) {
				ctx.ui.notify(items.join("\n"), "info");
			} else {
				ctx.ui.notify(
					`Unknown section: ${args}\n` +
					"Try: summary, all, tools, models, extensions, commands, context",
					"warning",
				);
			}
		},
	});
}
