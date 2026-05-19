import * as fs from 'fs';
import * as path from 'path';

export interface ManifestInfo {
    uri: string;
    hasTSFX: boolean;
    clientScripts: string[];
    serverScripts: string[];
    sharedScripts: string[];
}

/**
 * Scan a single fxmanifest.lua file for tsfx_sdk dependency.
 * Uses a lightweight regex / line-based scanner — no full Lua parser.
 */
export function parseManifest(filePath: string): ManifestInfo {
    const content = fs.readFileSync(filePath, 'utf-8');
    const lines = content.split(/\r?\n/);

    let inDependencies = false;
    let braceDepth = 0;
    let dependencyBlock = '';

    const clientScripts: string[] = [];
    const serverScripts: string[] = [];
    const sharedScripts: string[] = [];
    let currentBlock: 'client' | 'server' | 'shared' | null = null;

    for (const rawLine of lines) {
        const line = rawLine.trim();

        // Track script blocks
        if (/^client_scripts\s*\{/.test(line)) {
            currentBlock = 'client';
            continue;
        }
        if (/^server_scripts\s*\{/.test(line)) {
            currentBlock = 'server';
            continue;
        }
        if (/^shared_scripts\s*\{/.test(line)) {
            currentBlock = 'shared';
            continue;
        }
        if (line === '}' && currentBlock) {
            currentBlock = null;
            continue;
        }

        if (currentBlock && line.length > 0 && !line.startsWith('--')) {
            // Strip trailing comma and quotes
            const cleaned = line.replace(/,$/, '').trim().replace(/^['"]/, '').replace(/['"]$/g, '');
            if (cleaned) {
                if (currentBlock === 'client') clientScripts.push(cleaned);
                if (currentBlock === 'server') serverScripts.push(cleaned);
                if (currentBlock === 'shared') sharedScripts.push(cleaned);
            }
        }

        // Dependency block detection
        if (!inDependencies) {
            const depMatch = line.match(/^dependencies\s*\{/);
            if (depMatch) {
                inDependencies = true;
                braceDepth = 1;
                const openIdx = line.indexOf('{');
                dependencyBlock += line.slice(openIdx + 1);
                continue;
            }
        } else {
            dependencyBlock += '\n' + line;
            for (const ch of line) {
                if (ch === '{') braceDepth++;
                if (ch === '}') braceDepth--;
            }
            if (braceDepth <= 0) {
                inDependencies = false;
            }
        }
    }

    // Strip Lua comments from the dependency block, then look for tsfx_sdk
    const noComments = dependencyBlock
        .split('\n')
        .map((l) => {
            const idx = l.indexOf('--');
            return idx >= 0 ? l.slice(0, idx) : l;
        })
        .join('\n');

    const hasTSFX = /['"]\s*tsfx_sdk\s*['"]/.test(noComments);

    return {
        uri: filePath,
        hasTSFX,
        clientScripts,
        serverScripts,
        sharedScripts,
    };
}

/**
 * Resolve a glob-like pattern from fxmanifest.lua against the manifest directory.
 * Returns absolute file paths.
 */
export function resolveScriptGlobs(manifestDir: string, patterns: string[]): string[] {
    const resolved: string[] = [];
    for (const pattern of patterns) {
        if (pattern.includes('*')) {
            // Simple glob: either single file with wildcard or directory wildcard
            const base = pattern.split('*')[0];
            const dir = path.dirname(path.join(manifestDir, pattern));
            const fileName = path.basename(pattern);
            if (fs.existsSync(dir)) {
                const entries = fs.readdirSync(dir, { withFileTypes: true });
                for (const entry of entries) {
                    if (entry.isFile()) {
                        // Very naive wildcard matching for * and **
                        if (matchGlob(entry.name, fileName)) {
                            resolved.push(path.join(dir, entry.name));
                        }
                    }
                }
            }
        } else {
            const full = path.join(manifestDir, pattern);
            if (fs.existsSync(full)) {
                resolved.push(full);
            }
        }
    }
    return resolved;
}

function matchGlob(name: string, pattern: string): boolean {
    if (pattern === '*.lua') return name.endsWith('.lua');
    if (pattern === '**/*.lua') return name.endsWith('.lua');
    if (pattern === '*_index.lua') return name.endsWith('_index.lua');
    if (pattern === '*.lua') return name.endsWith('.lua');
    // Fallback: treat * as wildcard for any substring
    const parts = pattern.split('*');
    if (parts.length === 2 && parts[1] === '') {
        return name.startsWith(parts[0]);
    }
    if (parts.length === 2 && parts[0] === '') {
        return name.endsWith(parts[1]);
    }
    return name === pattern;
}
