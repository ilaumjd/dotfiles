#!/usr/bin/env node

const https = require("https");
const fs = require("fs");
const path = require("path");
const os = require("os");

const PROVIDERS_JSON = path.join(
	os.homedir(),
	".pi",
	"scripts",
	"providers.json",
);
const MODELS_JSON = path.join(os.homedir(), ".pi", "agent", "models.json");

const API = "openai-completions";
const EXCLUDE_RE = /embedding|tts|speech|whisper|moderation/i;

function fetchJson(url, apiKey) {
	return new Promise((resolve, reject) => {
		const client = url.startsWith("https:") ? https : require("http");
		const headers = { Accept: "application/json" };
		if (apiKey) {
			headers["Authorization"] = `Bearer ${apiKey}`;
		}
		const req = client.get(url, { headers }, (res) => {
			let data = "";
			res.on("data", (chunk) => (data += chunk));
			res.on("end", () => {
				try {
					const json = JSON.parse(data);
					if (json.error) {
						reject(new Error(json.error.message || JSON.stringify(json.error)));
						return;
					}
					resolve(json);
				} catch (e) {
					reject(new Error(`Invalid JSON from ${url}: ${e.message}`));
				}
			});
		});
		req.on("error", reject);
		req.setTimeout(30000, () => reject(new Error(`Timeout: ${url}`)));
	});
}

async function main() {
	let providersConfig = {};
	try {
		providersConfig = JSON.parse(fs.readFileSync(PROVIDERS_JSON, "utf-8"));
	} catch {
		console.error(`Failed to read ${PROVIDERS_JSON}`);
		process.exit(1);
	}

	const providers = {};

	for (const [name, config] of Object.entries(providersConfig)) {
		try {
			const baseUrl = config.url;
			const apiKey = config.apiKey;
			const json = await fetchJson(`${baseUrl}/models`, apiKey);
			let filtered = (json.data || []).filter(
				(m) => m.id && !EXCLUDE_RE.test(m.id),
			);

			if (
				config.whitelist &&
				Array.isArray(config.whitelist) &&
				config.whitelist.length > 0
			) {
				const patterns = config.whitelist.map((w) => w.toLowerCase());
				filtered = filtered.filter((m) =>
					patterns.some((p) => m.id.toLowerCase().includes(p)),
				);
			}

			if (
				config.blacklist &&
				Array.isArray(config.blacklist) &&
				config.blacklist.length > 0
			) {
				const patterns = config.blacklist.map((w) => w.toLowerCase());
				filtered = filtered.filter(
					(m) => !patterns.some((p) => m.id.toLowerCase().includes(p)),
				);
			}

			const models = filtered.map((m) => ({ id: m.id, reasoning: true }));

			providers[name] = {
				baseUrl,
				api: API,
				...(apiKey ? { apiKey } : {}),
				models,
			};

			console.error(`✓ ${name}: ${models.length} models`);
		} catch (err) {
			console.error(`✗ ${name}: ${err.message}`);
		}
	}

	fs.writeFileSync(MODELS_JSON, JSON.stringify({ providers }, null, 2) + "\n");
	console.error(`Wrote ${MODELS_JSON}`);
}

main().catch((err) => {
	console.error(err);
	process.exit(1);
});
