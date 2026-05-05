import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { readFileSync, readdirSync, existsSync } from "fs";
import { join } from "path";

// -------------------------------------------------------------------------
// Types
// -------------------------------------------------------------------------

interface Persona {
	name: string;
	description: string;
	tools: string[];
	blocklist: string[];
	systemPrompt: string;
	file: string;
}

interface PersonaConfig {
	defaultPersona: string;
	mainPersonas: string[];
}

// -------------------------------------------------------------------------
// Pure helpers (no side effects, testable)
// -------------------------------------------------------------------------

function parseFrontmatter(raw: string): Record<string, string> | null {
	const match = raw.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
	if (!match) return null;

	const frontmatter: Record<string, string> = {};
	for (const line of match[1].split("\n")) {
		const idx = line.indexOf(":");
		if (idx > 0) {
			frontmatter[line.slice(0, idx).trim()] = line.slice(idx + 1).trim();
		}
	}

	if (!frontmatter.name) return null;

	return frontmatter;
}

function splitList(value: string | undefined): string[] {
	if (!value) return [];
	return value.split(",").map((t) => t.trim()).filter(Boolean);
}

function parsePersonaFile(filePath: string): Persona | null {
	try {
		const raw = readFileSync(filePath, "utf-8");
		const frontmatter = parseFrontmatter(raw);
		if (!frontmatter) return null;

		// Legacy allowlist: tools + external_tools are merged
		const tools = [
			...splitList(frontmatter.tools),
			...splitList(frontmatter.external_tools),
		];

		return {
			name: frontmatter.name,
			description: frontmatter.description || "",
			tools,
			blocklist: splitList(frontmatter.blocklist),
			systemPrompt: raw.replace(/^---\n[\s\S]*?\n---\n/, "").trim(),
			file: filePath,
		};
	} catch {
		return null;
	}
}

function scanPersonas(dir: string): Persona[] {
	if (!existsSync(dir)) return [];

	const personas: Persona[] = [];
	const seen = new Set<string>();

	try {
		for (const file of readdirSync(dir)) {
			if (!file.endsWith(".md")) continue;
			const persona = parsePersonaFile(join(dir, file));
			if (persona && !seen.has(persona.name.toLowerCase())) {
				seen.add(persona.name.toLowerCase());
				personas.push(persona);
			}
		}
	} catch {
		// Directory unreadable — return empty
	}

	return personas;
}

function getDefaultPersonas(): Persona[] {
	return [
		{
			name: "default",
			description: "General-purpose coding assistant",
			tools: [],
			blocklist: [],
			systemPrompt:
				"You are a helpful coding assistant. Follow the user's instructions precisely.",
			file: "(built-in)",
		},
	];
}

function loadPersonaConfig(configPath: string): PersonaConfig {
	try {
		const raw = readFileSync(configPath, "utf-8");
		const parsed = JSON.parse(raw);
		return {
			defaultPersona: typeof parsed.defaultPersona === "string" ? parsed.defaultPersona : "plan",
			mainPersonas: Array.isArray(parsed.mainPersonas) ? parsed.mainPersonas.filter((s: unknown) => typeof s === "string") : [],
		};
	} catch {
		return { defaultPersona: "plan", mainPersonas: [] };
	}
}

function getLastPersonaFromSession(ctx: ExtensionContext): string | null {
	const entries = ctx.sessionManager.getEntries();
	for (let i = entries.length - 1; i >= 0; i--) {
		const entry = entries[i];
		if (entry.type === "custom" && (entry as any).customType === "persona-active") {
			return (entry as any).data?.name || null;
		}
	}
	return null;
}

function resolveActiveTools(persona: Persona, available: string[]): string[] {
	// 1. Legacy explicit allowlist
	if (persona.tools.length > 0) {
		return persona.tools;
	}
	// 2. Blocklist mode
	if (persona.blocklist.length > 0) {
		const blocked = new Set(persona.blocklist.map((t) => t.toLowerCase()));
		return available.filter((t) => !blocked.has(t.toLowerCase()));
	}
	// 3. Default to everything available
	return available;
}

function validatePersona(persona: Persona, available: string[]): void {
	const availableSet = new Set(available.map((t) => t.toLowerCase()));

	for (const tool of persona.blocklist) {
		if (!availableSet.has(tool.toLowerCase())) {
			console.warn(
				`[persona-toggle] "${persona.name}" blocklists unknown tool: "${tool}"`,
			);
		}
	}
	for (const tool of persona.tools) {
		if (!availableSet.has(tool.toLowerCase())) {
			console.warn(
				`[persona-toggle] "${persona.name}" allows unknown tool: "${tool}"`,
			);
		}
	}
}

// -------------------------------------------------------------------------
// Extension entry point
// -------------------------------------------------------------------------

export default function personaToggleExtension(pi: ExtensionAPI): void {
	const baseDir = join(
		process.env.HOME || process.env.USERPROFILE || ".",
		".pi",
		"agent",
	);
	const personasDir = join(baseDir, "personas");
	const configPath = join(baseDir, "persona-config.json");

	const config = loadPersonaConfig(configPath);

	let allPersonas = scanPersonas(personasDir);
	if (allPersonas.length === 0) {
		allPersonas = getDefaultPersonas();
	}

	let mainPersonas: Persona[];
	if (config.mainPersonas.length > 0) {
		mainPersonas = [];
		for (const name of config.mainPersonas) {
			const p = allPersonas.find(
				(p) => p.name.toLowerCase() === name.toLowerCase(),
			);
			if (p) {
				mainPersonas.push(p);
			} else {
				console.warn(
					`[persona-toggle] mainPersonas entry "${name}" not found`,
				);
			}
		}
		if (mainPersonas.length === 0) {
			mainPersonas = [...allPersonas];
		}
	} else {
		mainPersonas = [...allPersonas];
	}

	let activeIndex = 0;
	let mainIndex = 0;
	let validated = false;

	function getAvailableTools(): string[] {
		return pi.getAllTools().map((t) => t.name);
	}

	function syncMainIndex(): void {
		const persona = allPersonas[activeIndex];
		if (!persona) return;
		const idx = mainPersonas.findIndex(
			(p) => p.name.toLowerCase() === persona.name.toLowerCase(),
		);
		if (idx >= 0) mainIndex = idx;
	}

	function activatePersona(index: number, ctx: ExtensionContext): void {
		activeIndex = index;
		const persona = allPersonas[activeIndex];
		if (!persona) return;

		const available = getAvailableTools();

		// Best-effort validation on first activation (can't call during load)
		if (!validated) {
			for (const p of allPersonas) {
				validatePersona(p, available);
			}
			validated = true;
		}

		const activeTools = resolveActiveTools(persona, available);

		pi.setActiveTools(activeTools);
		ctx.ui.setStatus("persona", ctx.ui.theme.fg("accent", persona.name.toUpperCase()));
		pi.appendEntry("persona-active", { name: persona.name });
		syncMainIndex();
	}

	function cyclePersona(ctx: ExtensionContext): void {
		if (mainPersonas.length === 0) return;
		mainIndex = (mainIndex + 1) % mainPersonas.length;
		const target = mainPersonas[mainIndex];
		const idx = allPersonas.findIndex(
			(p) => p.name.toLowerCase() === target.name.toLowerCase(),
		);
		activatePersona(idx >= 0 ? idx : 0, ctx);
	}

	function restorePersona(name: string | null, ctx: ExtensionContext): void {
		if (!name) {
			const defaultIdx = allPersonas.findIndex(
				(p) => p.name.toLowerCase() === config.defaultPersona.toLowerCase(),
			);
			activatePersona(defaultIdx >= 0 ? defaultIdx : 0, ctx);
			return;
		}
		const idx = allPersonas.findIndex(
			(p) => p.name.toLowerCase() === name.toLowerCase(),
		);
		activatePersona(idx >= 0 ? idx : 0, ctx);
	}

	// --- Tab cycles main personas ---
	pi.registerShortcut("tab", {
		description: "Cycle to next main persona",
		handler: async (ctx) => cyclePersona(ctx),
	});

	// --- /personas selects from all personas ---
	pi.registerCommand("personas", {
		description: "Select a persona",
		handler: async (rawArgs, ctx) => {
			const args = (
				Array.isArray(rawArgs)
					? rawArgs.map(String)
					: typeof rawArgs === "string"
						? rawArgs.trim().split(/\s+/)
						: []
			).filter((s) => s.length > 0);

			if (args.length > 0) {
				const name = args.join(" ");
				const idx = allPersonas.findIndex(
					(p) => p.name.toLowerCase() === name.toLowerCase(),
				);
				if (idx >= 0) {
					activatePersona(idx, ctx);
					ctx.ui.notify(`Switched to ${allPersonas[idx].name}`, "success");
				} else {
					ctx.ui.notify(`Persona "${name}" not found`, "error");
				}
				return;
			}

			const list = allPersonas.map((p, i) => `${i + 1}. ${p.name}`).join("\n");
			ctx.ui.notify(`Personas:\n${list}`, "info");
		},
	});

	// --- Inject system prompt every turn ---
	pi.on("before_agent_start", async () => {
		const persona = allPersonas[activeIndex];
		if (!persona) return;
		return { systemPrompt: persona.systemPrompt };
	});

	// --- Restore on session lifecycle events ---
	pi.on("session_start", async (_event, ctx) => {
		const last = getLastPersonaFromSession(ctx);
		restorePersona(last, ctx);
	});

	pi.on("session_switch", async (_event, ctx) => {
		const last = getLastPersonaFromSession(ctx);
		restorePersona(last, ctx);
	});
}
