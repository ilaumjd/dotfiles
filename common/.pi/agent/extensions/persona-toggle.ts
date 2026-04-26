import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { readFileSync, readdirSync, existsSync } from "fs";
import { join } from "path";

const ALL_TOOLS = ["read", "write", "edit", "bash", "grep", "find", "ls"];

interface Persona {
	name: string;
	description: string;
	tools: string[];
	blocklist: string[];
	systemPrompt: string;
	file: string;
}

function parsePersonaFile(filePath: string): Persona | null {
	try {
		const raw = readFileSync(filePath, "utf-8");
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

		return {
			name: frontmatter.name,
			description: frontmatter.description || "",
			tools: [
				...(frontmatter.tools ? frontmatter.tools.split(",").map((t) => t.trim()) : []),
				...(frontmatter.external_tools ? frontmatter.external_tools.split(",").map((t) => t.trim()) : []),
			],
			blocklist: frontmatter.blocklist
				? frontmatter.blocklist.split(",").map((t) => t.trim())
				: [],
			systemPrompt: match[2].trim(),
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
	} catch {}
	return personas;
}

function getDefaultPersonas(): Persona[] {
	return [
		{
			name: "default",
			description: "General-purpose coding assistant",
			tools: [],
			blocklist: [],
			systemPrompt: "You are a helpful coding assistant. Follow the user's instructions precisely.",
			file: "(built-in)",
		},
	];
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

export default function personaToggleExtension(pi: ExtensionAPI): void {
	const personasDir = join(process.env.HOME || process.env.USERPROFILE || ".", ".pi", "agent", "personas");
	let personas = scanPersonas(personasDir);
	if (personas.length === 0) {
		personas = getDefaultPersonas();
	}

	const availableTools = getAvailableTools();
	for (const persona of personas) {
		validatePersona(persona, availableTools);
	}

	let activeIndex = 0;

	function getAvailableTools(): string[] {
		try {
			return pi.getAllTools().map((t) => t.name);
		} catch {
			return ALL_TOOLS;
		}
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

	function activatePersona(index: number, ctx: ExtensionContext): void {
		activeIndex = index;
		const persona = personas[activeIndex];
		if (!persona) return;

		const availableTools = getAvailableTools();
		const activeTools = resolveActiveTools(persona, availableTools);

		pi.setActiveTools(activeTools);
		ctx.ui.setStatus("persona", ctx.ui.theme.fg("accent", persona.name.toUpperCase()));
		pi.appendEntry("persona-active", { name: persona.name });
	}

	function cyclePersona(ctx: ExtensionContext): void {
		const next = (activeIndex + 1) % personas.length;
		activatePersona(next, ctx);
	}

	function restorePersona(name: string | null, ctx: ExtensionContext): void {
		if (!name) {
			// Default to "plan" persona on new sessions
			const planIdx = personas.findIndex((p) => p.name.toLowerCase() === "plan");
			activatePersona(planIdx >= 0 ? planIdx : 0, ctx);
			return;
		}
		const idx = personas.findIndex((p) => p.name.toLowerCase() === name.toLowerCase());
		activatePersona(idx >= 0 ? idx : 0, ctx);
	}

	// Tab cycles personas
	pi.registerShortcut("tab", {
		description: "Cycle to next persona",
		handler: async (ctx) => {
			cyclePersona(ctx);
		},
	});

	// Inject active persona system prompt every turn
	pi.on("before_agent_start", async () => {
		const persona = personas[activeIndex];
		if (!persona) return;
		return {
			systemPrompt: persona.systemPrompt,
		};
	});

	// Restore on session start / resume / reload
	pi.on("session_start", async (_event, ctx) => {
		const last = getLastPersonaFromSession(ctx);
		restorePersona(last, ctx);
	});

	// Restore on session switch
	pi.on("session_switch", async (_event, ctx) => {
		const last = getLastPersonaFromSession(ctx);
		restorePersona(last, ctx);
	});
}
