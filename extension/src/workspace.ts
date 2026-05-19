import * as path from 'path';
import * as vscode from 'vscode';
import { ManifestInfo, parseManifest, resolveScriptGlobs } from './utils/manifestParser';

let _manifests: ManifestInfo[] = [];
let _isTSFX = false;
let _fileContextMap = new Map<string, 'client' | 'server' | 'shared'>();

export async function findManifests(): Promise<ManifestInfo[]> {
    const files = await vscode.workspace.findFiles('**/fxmanifest.lua', '**/node_modules/**', 50);
    const manifests: ManifestInfo[] = [];
    _fileContextMap = new Map();

    for (const file of files) {
        try {
            const info = parseManifest(file.fsPath);
            manifests.push(info);

            const manifestDir = path.dirname(file.fsPath);
            const clientFiles = resolveScriptGlobs(manifestDir, info.clientScripts);
            const serverFiles = resolveScriptGlobs(manifestDir, info.serverScripts);
            const sharedFiles = resolveScriptGlobs(manifestDir, info.sharedScripts);

            for (const f of clientFiles) {
                _fileContextMap.set(f, 'client');
            }
            for (const f of serverFiles) {
                _fileContextMap.set(f, 'server');
            }
            for (const f of sharedFiles) {
                _fileContextMap.set(f, 'shared');
            }
        } catch (err) {
            console.error(`[TSFX SDK] Failed to parse manifest ${file.fsPath}:`, err);
        }
    }

    _manifests = manifests;
    _isTSFX = manifests.some((m) => m.hasTSFX);
    return manifests;
}

export function getManifests(): ManifestInfo[] {
    return _manifests;
}

export function hasTSFXDependency(): boolean {
    return _isTSFX;
}

export function isTSFXWorkspace(): boolean {
    return _isTSFX;
}

export function getFileContext(filePath: string): 'client' | 'server' | 'shared' | null {
    return _fileContextMap.get(filePath) ?? null;
}

export function resetWorkspaceState(): void {
    _manifests = [];
    _isTSFX = false;
    _fileContextMap = new Map();
}
