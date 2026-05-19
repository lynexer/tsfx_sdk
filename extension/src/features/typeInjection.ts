import * as fs from 'fs';
import * as path from 'path';
import * as vscode from 'vscode';

const LIBRARY_SETTING = 'workspace.library';
const LUA_CONFIG_SECTION = 'Lua';

function resolveTypesPath(context: vscode.ExtensionContext): string {
    // During local development the extension runs from the monorepo workspace.
    // Prefer the live types directory so edits are reflected immediately.
    const workspaceFolders = vscode.workspace.workspaceFolders;
    if (workspaceFolders) {
        for (const folder of workspaceFolders) {
            const liveTypes = path.join(folder.uri.fsPath, 'resource', 'shared', 'types');
            if (fs.existsSync(liveTypes)) {
                return liveTypes.replace(/\\/g, '/');
            }
        }
    }

    // Published installs fall back to the bundled types copied at build time.
    return context.asAbsolutePath('types').replace(/\\/g, '/');
}

export async function injectTypes(context: vscode.ExtensionContext): Promise<void> {
    try {
        const config = vscode.workspace.getConfiguration(LUA_CONFIG_SECTION);
        const library = config.get<string[]>(LIBRARY_SETTING) ?? [];
        const typesPath = resolveTypesPath(context);

        if (library.includes(typesPath)) {
            return;
        }

        await config.update(LIBRARY_SETTING, [...library, typesPath], vscode.ConfigurationTarget.Workspace);
        console.log(`[TSFX SDK] Injected types path: ${typesPath}`);

        const reloadAction = 'Reload Window';
        const choice = await vscode.window.showInformationMessage(
            'TSFX SDK types have been configured. Reload VS Code to activate IntelliSense.',
            reloadAction,
        );
        if (choice === reloadAction) {
            await vscode.commands.executeCommand('workbench.action.reloadWindow');
        }
    } catch (err) {
        console.error('[TSFX SDK] Failed to inject LuaLS types:', err);
    }
}

export async function removeTypes(context: vscode.ExtensionContext): Promise<void> {
    try {
        const config = vscode.workspace.getConfiguration(LUA_CONFIG_SECTION);
        const library = config.get<string[]>(LIBRARY_SETTING) ?? [];
        const typesPath = resolveTypesPath(context);

        if (!library.includes(typesPath)) {
            return;
        }

        const filtered = library.filter((p) => p !== typesPath);
        await config.update(LIBRARY_SETTING, filtered, vscode.ConfigurationTarget.Workspace);
        console.log(`[TSFX SDK] Removed types path: ${typesPath}`);
    } catch (err) {
        console.error('[TSFX SDK] Failed to remove LuaLS types:', err);
    }
}
