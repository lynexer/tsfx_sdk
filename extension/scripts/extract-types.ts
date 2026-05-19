import * as fs from 'fs';
import * as path from 'path';

const SCRIPT_DIR = __dirname;
const SOURCE_DIR = path.resolve(SCRIPT_DIR, '..', '..', 'resource', 'shared', 'types');
const DEST_DIR = path.resolve(SCRIPT_DIR, '..', 'types');
const FXMANIFEST_PATH = path.resolve(SCRIPT_DIR, '..', '..', 'resource', 'fxmanifest.lua');

interface TypeManifest {
    version: string;
    files: string[];
    generatedAt: string;
}

function walkLuaFiles(dir: string): string[] {
    const results: string[] = [];
    const entries = fs.readdirSync(dir, { withFileTypes: true });
    for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);
        if (entry.isDirectory()) {
            results.push(...walkLuaFiles(fullPath));
        } else if (entry.isFile() && entry.name.endsWith('.lua')) {
            results.push(fullPath);
        }
    }
    return results;
}

function main(): void {
    if (!fs.existsSync(SOURCE_DIR)) {
        console.error(`[extract-types] Source directory does not exist: ${SOURCE_DIR}`);
        process.exit(1);
    }

    // Clean and recreate destination
    if (fs.existsSync(DEST_DIR)) {
        fs.rmSync(DEST_DIR, { recursive: true, force: true });
    }
    fs.mkdirSync(DEST_DIR, { recursive: true });

    const files = walkLuaFiles(SOURCE_DIR);
    const relativeFiles: string[] = [];

    for (const file of files) {
        const content = fs.readFileSync(file, 'utf-8');
        const lines = content.split(/\r?\n/);
        const firstTenRealLines = lines.filter((l) => l.trim().length > 0).slice(0, 10);
        const hasMeta = firstTenRealLines.some((l) => l.trim().startsWith('--- @meta'));

        if (!hasMeta) {
            console.error(`[extract-types] MISSING @meta HEADER: ${path.relative(SOURCE_DIR, file)}`);
            console.error(`  First 10 non-empty lines:`);
            for (const line of firstTenRealLines) {
                console.error(`    ${line}`);
            }
            process.exit(1);
        }

        const relPath = path.relative(SOURCE_DIR, file);
        const destPath = path.join(DEST_DIR, relPath);
        const destDir = path.dirname(destPath);

        fs.mkdirSync(destDir, { recursive: true });
        fs.copyFileSync(file, destPath);
        relativeFiles.push(relPath.replace(/\\/g, '/'));
        console.log(`[extract-types] Copied ${relPath}`);
    }

    // Extract version from fxmanifest.lua
    let version = '0.0.0';
    if (fs.existsSync(FXMANIFEST_PATH)) {
        const manifestContent = fs.readFileSync(FXMANIFEST_PATH, 'utf-8');
        const versionMatch = manifestContent.match(/(?:^|\n)version\s+['"]([^'"]+)['"]/);
        if (versionMatch) {
            version = versionMatch[1];
        } else {
            console.warn('[extract-types] Could not find version in fxmanifest.lua, defaulting to 0.0.0');
        }
    } else {
        console.warn('[extract-types] fxmanifest.lua not found, defaulting version to 0.0.0');
    }

    const manifest: TypeManifest = {
        version,
        files: relativeFiles,
        generatedAt: new Date().toISOString(),
    };

    const manifestPath = path.join(DEST_DIR, 'index.json');
    fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2), 'utf-8');
    console.log(`[extract-types] Wrote ${manifestPath}`);
    console.log(`[extract-types] Done. Version ${version}, ${relativeFiles.length} files.`);
}

main();
