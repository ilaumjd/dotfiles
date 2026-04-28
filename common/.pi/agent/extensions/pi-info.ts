/**
 * Pi Info Extension
 *
 * One-command overview of everything: pi version, model, providers,
 * tools, extensions, themes, session stats, context usage, etc.
 *
 * Usage:
 *   /info                → compact summary popup
 *   /info all            → full scrollable selector
 *   /info model          → current model details
 *   /info tools          → active + all tools
 *   /info providers      → all providers & models
 *   /info extensions     → loaded extensions
 *   /info commands       → slash commands
 *   /info session        → session metadata
 *   /info theme          → current & available themes
 *   /info context        → context usage stats
 *   /info thinking       → thinking level
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

	const model = ctx.model;
	const modelLine = model
		? `${model.provider} / ${model.id}`
		: "none";

	const thinking = pi.getThinkingLevel();

	const usage = ctx.getContextUsage();
	const ctxLine = usage
		? `${usage.tokens?.toLocaleString() ?? "?"} / ${usage.contextWindow.toLocaleString()} (${usage.percent?.toFixed(1) ?? "?"}%)`
		: "n/a";

	const activeTools = pi.getActiveTools().length;
	const totalTools = pi.getAllTools().length;

	const globalExts = scanExtDir(join(homedir(), ".pi", "agent", "extensions")).length;
	const localExts = scanExtDir(join(ctx.cwd, ".pi", "extensions")).length;
	const npmPkgs = (settings.packages ?? []).length;

	const currentTheme = ctx.ui.theme.name ?? settings.theme ?? "default";

	const lines = [
		theme.bold("Pi Info"),
		"",
		`${theme.fg("dim", "Version:")}  ${theme.fg("accent", version)}`,
		`${theme.fg("dim", "Model:")}     ${modelLine}`,
		`${theme.fg("dim", "Thinking:")}  ${thinking}`,
		`${theme.fg("dim", "Context:")}   ${ctxLine}`,
		`${theme.fg("dim", "Tools:")}     ${activeTools} active / ${totalTools} total`,
		`${theme.fg("dim", "Exts:")}      ${globalExts} global + ${localExts} local + ${npmPkgs} npm`,
		`${theme.fg("dim", "Theme:")}     ${currentTheme}`,
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

	// --- Session ---
	items.push(theme.bold("━━━ Session ━━━"));
	const name = pi.getSessionName();
	if (name) items.push(`Name:    ${name}`);
	items.push(`File:    ${ctx.sessionManager.getSessionFile() ?? "In-memory"}`);
	items.push(`ID:      ${ctx.sessionManager.getSessionId()}`);
	items.push(`CWD:     ${ctx.cwd}`);
	const msgCount = ctx.sessionManager.getEntries().filter((e) => e.type === "message").length;
	items.push(`Messages: ${msgCount}`);
	items.push("");

	// --- Model ---
	items.push(theme.bold("━━━ Model ━━━"));
	const m = ctx.model;
	if (m) {
		items.push(`Provider:  ${m.provider}`);
		items.push(`ID:        ${m.id}`);
		items.push(`Name:      ${m.name}`);
		items.push(`API:       ${m.api}`);
		items.push(`Reasoning: ${m.reasoning}`);
		items.push(`Context:   ${m.contextWindow.toLocaleString()}`);
		items.push(`MaxTokens: ${m.maxTokens.toLocaleString()}`);
		items.push(`Cost:      in=${m.cost.input} out=${m.cost.output} cacheR=${m.cost.cacheRead} cacheW=${m.cost.cacheWrite}`);
	} else {
		items.push("No model selected");
	}
	items.push("");

	// --- Thinking ---
	items.push(theme.bold("━━━ Thinking ━━━"));
	items.push(`Level: ${pi.getThinkingLevel()}`);
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

	// --- Providers & Models ---
	const availableModels = ctx.modelRegistry.getAvailable();
	items.push(theme.bold(`━━━ Providers & Models (${availableModels.length} available) ━━━`));
	const byProvider = new Map<string, typeof availableModels>();
	for (const model of availableModels) {
		const list = byProvider.get(model.provider) ?? [];
		list.push(model);
		byProvider.set(model.provider, list);
	}
	for (const [provider, models] of [...byProvider.entries()].sort((a, b) => a[0].localeCompare(b[0]))) {
		items.push(`${theme.fg("accent", provider)} (${models.length})`);
		for (const model of models) {
			items.push(`  ${model.id}`);
		}
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

	// --- Theme ---
	items.push(theme.bold("━━━ Theme ━━━"));
	items.push(`Current: ${ctx.ui.theme.name ?? settings.theme ?? "default"}`);
	const themes = ctx.ui.getAllThemes();
	items.push(`Available (${themes.length}): ${themes.map((t) => t.name).join(", ")}`);

	return items;
}

// -------------------------------------------------------------------------
// Per-section builders
// -------------------------------------------------------------------------

function buildModelItems(ctx: ExtensionCommandContext): string[] {
	const m = ctx.model;
	if (!m) return ["No model selected"];
	return [
		`Provider:  ${m.provider}`,
		`ID:        ${m.id}`,
		`Name:      ${m.name}`,
		`API:       ${m.api}`,
		`Reasoning: ${m.reasoning}`,
		`Context:   ${m.contextWindow.toLocaleString()}`,
		`MaxTokens: ${m.maxTokens.toLocaleString()}`,
		`Cost:      in=${m.cost.input} out=${m.cost.output} cacheR=${m.cost.cacheRead} cacheW=${m.cost.cacheWrite}`,
	];
}

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

function buildProvidersItems(ctx: ExtensionCommandContext): string[] {
	const items: string[] = [];
	const availableModels = ctx.modelRegistry.getAvailable();
	const byProvider = new Map<string, typeof availableModels>();
	for (const model of availableModels) {
		const list = byProvider.get(model.provider) ?? [];
		list.push(model);
		byProvider.set(model.provider, list);
	}
	if (byProvider.size === 0) {
		items.push("No providers connected (no API keys configured)");
		return items;
	}
	for (const [provider, models] of [...byProvider.entries()].sort((a, b) => a[0].localeCompare(b[0]))) {
		items.push(`${provider} (${models.length})`);
		for (const model of models) {
			items.push(`  ${model.id}`);
		}
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

function buildSessionItems(pi: ExtensionAPI, ctx: ExtensionCommandContext): string[] {
	const items: string[] = [];
	const name = pi.getSessionName();
	if (name) items.push(`Name: ${name}`);
	items.push(`File: ${ctx.sessionManager.getSessionFile() ?? "In-memory"}`);
	items.push(`ID:   ${ctx.sessionManager.getSessionId()}`);
	items.push(`CWD:  ${ctx.cwd}`);
	const counts = ctx.sessionManager.getEntries().reduce(
		(acc, e) => {
			if (e.type === "message") {
				if (e.message.role === "user") acc.user++;
				else if (e.message.role === "assistant") acc.assistant++;
				else if (e.message.role === "toolResult") acc.tool++;
			}
			return acc;
		},
		{ user: 0, assistant: 0, tool: 0 },
	);
	items.push("");
	items.push(`User:      ${counts.user}`);
	items.push(`Assistant: ${counts.assistant}`);
	items.push(`Tool:      ${counts.tool}`);
	items.push(`Total:     ${counts.user + counts.assistant + counts.tool}`);
	return items;
}

function buildThemeItems(ctx: ExtensionCommandContext): string[] {
	const themes = ctx.ui.getAllThemes();
	return [
		`Current: ${ctx.ui.theme.name ?? "default"}`,
		"",
		`Available (${themes.length}):`,
		...themes.map((t) => `  ${t.name}`),
	];
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

function buildThinkingItems(pi: ExtensionAPI): string[] {
	return [`Current level: ${pi.getThinkingLevel()}`];
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
		case "model":
			return buildModelItems(ctx);
		case "tools":
			return buildToolsItems(pi, ctx);
		case "providers":
			return buildProvidersItems(ctx);
		case "extensions":
			return buildExtensionsItems(ctx);
		case "commands":
			return buildCommandsItems(pi);
		case "session":
			return buildSessionItems(pi, ctx);
		case "theme":
			return buildThemeItems(ctx);
		case "context":
			return buildContextItems(ctx);
		case "thinking":
			return buildThinkingItems(pi);
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
			"Show pi system info (version, model, tools, providers, extensions, theme, etc.)",
		getArgumentCompletions: (prefix) => {
			const opts = [
				"summary",
				"all",
				"model",
				"tools",
				"providers",
				"extensions",
				"commands",
				"session",
				"theme",
				"context",
				"thinking",
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
				await ctx.ui.select("Pi System Info", items);
				return;
			}

			const items = buildSectionItems(pi, ctx, args);
			if (items.length > 0) {
				await ctx.ui.select(`Pi Info — ${args}`, items);
			} else {
				ctx.ui.notify(
					`Unknown section: ${args}\n` +
					"Try: summary, all, model, tools, providers, extensions, commands, session, theme, context, thinking",
					"warning",
				);
			}
		},
	});
}
