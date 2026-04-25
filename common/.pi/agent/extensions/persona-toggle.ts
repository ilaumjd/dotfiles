import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { readFileSync, readdirSync, existsSync } from "fs";
import { join } from "path";

const ALL_TOOLS = ["read", "write", "edit", "bash", "grep", "find", "ls"];

interface Persona {
	name: string;
	description: string;
	tools: string[];
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
			tools: frontmatter.tools ? frontmatter.tools.split(",").map((t) => t.trim()) : [],
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
			tools: ALL_TOOLS,
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

	let activeIndex = 0;

	function activatePersona(index: number, ctx: ExtensionContext): void {
		activeIndex = index;
		const persona = personas[activeIndex];
		if (!persona) return;

		pi.setActiveTools(persona.tools.length > 0 ? persona.tools : ALL_TOOLS);
		ctx.ui.setStatus("persona", ctx.ui.theme.fg("accent", persona.name.toUpperCase()));
		pi.appendEntry("persona-active", { name: persona.name });
	}

	function cyclePersona(ctx: ExtensionContext): void {
		const next = (activeIndex + 1) % personas.length;
		activatePersona(next, ctx);
	}

	function restorePersona(name: string | null, ctx: ExtensionContext): void {
		if (!name) {
			activatePersona(0, ctx);
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
