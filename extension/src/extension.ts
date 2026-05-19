import * as vscode from 'vscode';
import { subscribeToDocumentChanges } from './features/diagnostics';
import { injectTypes, removeTypes } from './features/typeInjection';
import { findManifests, isTSFXWorkspace, resetWorkspaceState } from './workspace';

let statusBarItem: vscode.StatusBarItem;
let fileWatcher: vscode.FileSystemWatcher | undefined;
let _context: vscode.ExtensionContext;

export async function activate(context: vscode.ExtensionContext): Promise<void> {
    _context = context;
    console.log('[TSFX SDK] Extension activated');

    // Status bar
    statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
    statusBarItem.command = 'tsfx.reloadWorkspace';
    context.subscriptions.push(statusBarItem);

    // Initial workspace scan
    await evaluateWorkspace();

    // File watcher for manifest changes
    fileWatcher = vscode.workspace.createFileSystemWatcher('**/fxmanifest.lua', false, false, false);
    fileWatcher.onDidChange(() => evaluateWorkspace());
    fileWatcher.onDidCreate(() => evaluateWorkspace());
    fileWatcher.onDidDelete(() => evaluateWorkspace());
    context.subscriptions.push(fileWatcher);

    // Register reload command
    const reloadCommand = vscode.commands.registerCommand('tsfx.reloadWorkspace', async () => {
        await evaluateWorkspace();
        vscode.window.showInformationMessage('TSFX SDK workspace detection reloaded');
    });
    context.subscriptions.push(reloadCommand);

    // Subscribe to document changes for diagnostics
    subscribeToDocumentChanges(context);
}

export async function deactivate(): Promise<void> {
    console.log('[TSFX SDK] Extension deactivated');
    await removeTypes(_context);
    resetWorkspaceState();
    statusBarItem?.dispose();
    fileWatcher?.dispose();
}

async function evaluateWorkspace(): Promise<void> {
    resetWorkspaceState();
    await findManifests();

    if (isTSFXWorkspace()) {
        statusBarItem.text = '$(check) TSFX SDK: Active';
        statusBarItem.tooltip = 'TSFX SDK dependency detected in this workspace';
        statusBarItem.show();
        console.log('[TSFX SDK] Workspace detected as TSFX');
        await injectTypes(_context);
    } else {
        statusBarItem.text = '$(circle-slash) TSFX SDK: Not detected';
        statusBarItem.tooltip = 'No fxmanifest.lua with tsfx_sdk dependency found';
        await removeTypes(_context);
        // Hide status bar if no manifest found at all, otherwise show "not detected"
        const anyManifest = (await vscode.workspace.findFiles('**/fxmanifest.lua', '**/node_modules/**', 1)).length > 0;
        if (anyManifest) {
            statusBarItem.show();
        } else {
            statusBarItem.hide();
        }
    }
}
