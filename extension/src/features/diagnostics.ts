import * as vscode from 'vscode';
import { getFileContext, isTSFXWorkspace } from '../workspace';

const DIAGNOSTIC_COLLECTION = vscode.languages.createDiagnosticCollection('tsfx');

const SERVER_ONLY_METHODS = new Set([
    'addMoney', 'removeMoney', 'setMoney', 'setJob', 'setGang',
    'setDuty', 'setMetadata', 'removeMetadata', 'setRoutingBucket',
    'drop', 'getRoutingBucket',
]);

const CLIENT_ONLY_METHODS = new Set([
    'getPlayerId', 'isDead', 'isDriver', 'isInWater', 'isOnFoot',
    'isSprinting', 'isClimbing', 'isDiving', 'isSwimming', 'isTalking',
    'isAiming', 'isShooting', 'isReloading', 'playAnimation', 'stopAnimation',
    'isPlayingAnimation', 'clearTasks', 'getVehicleSeat',
]);

const VALID_MONEY_ACCOUNTS = new Set(['bank', 'cash', 'black_money']);

let _serverRegex: RegExp | null = null;
let _clientRegex: RegExp | null = null;
let _moneyRegex: RegExp | null = null;

function getServerRegex(): RegExp {
    if (!_serverRegex) {
        _serverRegex = new RegExp(`:(?:${[...SERVER_ONLY_METHODS].join('|')})\\s*\\(`, 'g');
    }
    return _serverRegex;
}

function getClientRegex(): RegExp {
    if (!_clientRegex) {
        _clientRegex = new RegExp(`:(?:${[...CLIENT_ONLY_METHODS].join('|')})\\s*\\(`, 'g');
    }
    return _clientRegex;
}

function getMoneyRegex(): RegExp {
    if (!_moneyRegex) {
        _moneyRegex = /:(?:addMoney|removeMoney|setMoney)\s*\(\s*['"]([^'"]+)['"]/g;
    }
    return _moneyRegex;
}

function isLineCommented(text: string, offset: number): boolean {
    const lineStart = text.lastIndexOf('\n', offset) + 1;
    const beforeMatch = text.slice(lineStart, offset).trimStart();
    return beforeMatch.startsWith('--');
}

export function refreshDiagnostics(document: vscode.TextDocument): void {
    if (!isTSFXWorkspace() || document.languageId !== 'lua') {
        DIAGNOSTIC_COLLECTION.delete(document.uri);
        return;
    }

    const diagnostics: vscode.Diagnostic[] = [];
    const fileContext = getFileContext(document.fileName);

    if (fileContext && fileContext !== 'shared') {
        checkWrongContext(document, fileContext, diagnostics);
    }

    checkUnknownMoneyAccount(document, diagnostics);

    DIAGNOSTIC_COLLECTION.set(document.uri, diagnostics);
}

function checkWrongContext(
    document: vscode.TextDocument,
    fileContext: 'client' | 'server',
    diagnostics: vscode.Diagnostic[]
): void {
    const config = vscode.workspace.getConfiguration('tsfx.diagnostics');
    if (!config.get<boolean>('wrongContext', true)) return;

    const text = document.getText();
    const forbiddenSet = fileContext === 'client' ? SERVER_ONLY_METHODS : CLIENT_ONLY_METHODS;
    const regex = fileContext === 'client' ? getServerRegex() : getClientRegex();

    let match: RegExpExecArray | null;
    while ((match = regex.exec(text)) !== null) {
        if (isLineCommented(text, match.index)) continue;

        const methodName = match[0].slice(1).split('(')[0].trim();
        if (!forbiddenSet.has(methodName)) continue;

        const startPos = document.positionAt(match.index);
        const endPos = document.positionAt(match.index + match[0].length);
        const range = new vscode.Range(startPos, endPos);

        const side = fileContext === 'client' ? 'server-only' : 'client-only';
        diagnostics.push(
            new vscode.Diagnostic(
                range,
                `TSFX SDK: "${methodName}" is ${side} and cannot be called in a ${fileContext}-side file.`,
                vscode.DiagnosticSeverity.Warning,
            ),
        );
    }
}

function checkUnknownMoneyAccount(document: vscode.TextDocument, diagnostics: vscode.Diagnostic[]): void {
    const config = vscode.workspace.getConfiguration('tsfx.diagnostics');
    if (!config.get<boolean>('unknownMoneyAccount', true)) return;

    const text = document.getText();
    const regex = getMoneyRegex();

    let match: RegExpExecArray | null;
    while ((match = regex.exec(text)) !== null) {
        if (isLineCommented(text, match.index)) continue;

        const account = match[1];
        if (VALID_MONEY_ACCOUNTS.has(account)) continue;

        const quoteStart = match[0].indexOf(account) - 1;
        const startPos = document.positionAt(match.index + quoteStart);
        const endPos = document.positionAt(match.index + quoteStart + account.length + 2);
        const range = new vscode.Range(startPos, endPos);

        diagnostics.push(
            new vscode.Diagnostic(
                range,
                `TSFX SDK: Unknown money account "${account}". Valid accounts are: bank, cash, black_money.`,
                vscode.DiagnosticSeverity.Warning,
            ),
        );
    }
}

let _timeout: NodeJS.Timeout | null = null;

export function subscribeToDocumentChanges(context: vscode.ExtensionContext): void {
    for (const doc of vscode.workspace.textDocuments) {
        if (doc.languageId === 'lua') {
            refreshDiagnostics(doc);
        }
    }

    context.subscriptions.push(
        vscode.workspace.onDidOpenTextDocument((doc) => {
            if (doc.languageId === 'lua') {
                refreshDiagnostics(doc);
            }
        }),
    );

    context.subscriptions.push(
        vscode.workspace.onDidChangeTextDocument((e) => {
            if (e.document.languageId !== 'lua') return;
            if (_timeout) clearTimeout(_timeout);
            _timeout = setTimeout(() => {
                refreshDiagnostics(e.document);
            }, 150);
        }),
    );

    context.subscriptions.push(
        vscode.workspace.onDidCloseTextDocument((doc) => {
            DIAGNOSTIC_COLLECTION.delete(doc.uri);
        }),
    );
}
