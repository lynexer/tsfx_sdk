import path from 'node:path';
import { fileURLToPath } from 'node:url';
import fs from 'fs-extra';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export interface FacadeMethod {
	name: string;
	params: { name: string; type: string; optional: boolean }[];
	returns: string | null;
	isServerOnly: boolean;
	isClientOnly: boolean;
}

export interface FacadeInfo {
	fileName: string;
	namespace: string;
	context: 'shared' | 'server' | 'client';
	className?: string;
	callable: boolean;
	implName?: string;
	explicitMethods: string[];
	constructorParams: { name: string; type: string; optional: boolean }[];
	methods: FacadeMethod[];
}

function extractStrings(content: string): string[] {
	const results: string[] = [];
	const regex = /'([^']+)'/g;
	let m: RegExpExecArray | null;
	while ((m = regex.exec(content)) !== null) {
		results.push(m[1]);
	}
	return results;
}

export function extractParamsBefore(content: string, pos: number): { name: string; type: string; optional: boolean }[] {
	const params: { name: string; type: string; optional: boolean }[] = [];
	const before = content.slice(0, pos);
	const lines = before.split('\n');
	for (let i = lines.length - 1; i >= 0; i--) {
		const line = lines[i].trim();
		if (line.startsWith('---@param')) {
			const m = line.match(/---@param\s+(\w+)(\??)\s+([^\r\n]+)/);
			if (m && m[1] !== 'self') {
				params.unshift({ name: m[1], type: m[3].trim(), optional: m[2] === '?' || m[3].includes('|nil') });
			}
		} else if (line.startsWith('---') || line === '') {
			continue;
		} else {
			break;
		}
	}
	return params;
}

function extractReturnBefore(content: string, pos: number): string | null {
	const before = content.slice(0, pos);
	const lines = before.split('\n');
	for (let i = lines.length - 1; i >= 0; i--) {
		const line = lines[i].trim();
		if (line.startsWith('---@return')) {
			const m = line.match(/---@return\s+([^\r\n]+)/);
			return m ? m[1].trim() : null;
		} else if (line.startsWith('---') || line === '') {
			continue;
		} else {
			break;
		}
	}
	return null;
}

export function parseRawParams(raw: string): { name: string; type: string; optional: boolean }[] {
	if (!raw.trim()) return [];
	return raw.split(',').map(p => {
		const trimmed = p.trim();
		if (trimmed === '' || trimmed === 'self') return null;
		const optional = trimmed.endsWith('?');
		const name = optional ? trimmed.slice(0, -1) : trimmed;
		return { name, type: 'any', optional };
	}).filter((p): p is { name: string; type: string; optional: boolean } => p !== null);
}

function simpleType(type: string): string {
	if (type.includes('vector4') && !type.includes('vector3')) return 'vector4';
	if (type.includes('vector3')) return 'vector3';
	if (type.includes('number') || type.includes('integer') || type.includes('float')) return 'number';
	if (type.includes('boolean')) return 'boolean';
	if (type.includes('string')) return 'string';
	return 'any';
}

function isComplexType(type: string): boolean {
	const simple = ['number', 'integer', 'float', 'string', 'boolean', 'vector3', 'vector4', 'any', 'table'];
	return !simple.some(p => type.toLowerCase().includes(p));
}

export function parseFacadeFile(filePath: string): FacadeInfo | null {
	const content = fs.readFileSync(filePath, 'utf-8');
	const fileName = path.basename(filePath);

	const moduleMatch = content.match(/return\s+Module\('([^']+)', '([^']+)'\)/);
	if (!moduleMatch) return null;

	const namespace = moduleMatch[1];
	const context = moduleMatch[2] as 'shared' | 'server' | 'client';

	const callable = /:callable\(\)/.test(content);
	const globalNameMatch = content.match(/:globalName\('([^']+)'\)/);
	const className = globalNameMatch ? globalNameMatch[1] : undefined;

	const implMatch = content.match(/:impl\((\w+)\)/);
	const implName = implMatch ? implMatch[1] : undefined;

	const explicitMethods: string[] = [];
	const methodsBlockMatch = content.match(/:methods\(function\s*\(m\)([\s\S]*?)end\)/);
	if (methodsBlockMatch) {
		const block = methodsBlockMatch[1];
		const adds = block.matchAll(/m:add\(([^)]+)\)/g);
		for (const add of adds) {
			const strings = extractStrings(add[1]);
			explicitMethods.push(...strings);
		}
	}

	const constructorParams: { name: string; type: string; optional: boolean }[] = [];
	if (className && callable) {
		const ctorRegex = new RegExp(`function\\s+${className}\\.new\\(([^)]*)\\)`, 'g');
		const ctorMatch = ctorRegex.exec(content);
		if (ctorMatch) {
			const funcStart = content.indexOf(ctorMatch[0]);
			constructorParams.push(...extractParamsBefore(content, funcStart));
		}
	}

	const methods: FacadeMethod[] = [];
	const methodRegex = new RegExp(`function\\s+(\\w+)[.:](\\w+)\\(([^)]*)\\)`, 'g');
	let match: RegExpExecArray | null;
	while ((match = methodRegex.exec(content)) !== null) {
		const funcClass = match[1];
		const funcName = match[2];

		if (funcName === 'new') continue;
		if (funcName.startsWith('_')) continue;
		if (funcClass !== className && funcClass !== implName) continue;

		const funcStart = content.indexOf(match[0]);
		let params = extractParamsBefore(content, funcStart);
		if (params.length === 0) {
			params = parseRawParams(match[3]);
		}
		const returns = extractReturnBefore(content, funcStart);

		// Determine server/client restriction by examining the function body
		const nextFunc = content.indexOf('function ', funcStart + match[0].length);
		const funcBody = content.slice(funcStart, nextFunc > 0 ? nextFunc : undefined);
		const isServerOnly = /:_serverOnly\('[^']+'\s*,/.test(funcBody);
		const isClientOnly = /:_clientOnly\('[^']+'\s*,/.test(funcBody);

		methods.push({
			name: funcName,
			params,
			returns,
			isServerOnly,
			isClientOnly,
		});
	}

	// For impl facades, add any explicit methods not found via regex
	if (implName && explicitMethods.length > 0) {
		for (const methodName of explicitMethods) {
			if (methods.some(m => m.name === methodName)) continue;
			const methodRegex = new RegExp(`function\\s+${implName}\\.${methodName}\\(([^)]*)\\)`, 'g');
			const m = methodRegex.exec(content);
			if (m) {
				const funcStart = content.indexOf(m[0]);
				let params = extractParamsBefore(content, funcStart);
				if (params.length === 0) {
					params = parseRawParams(m[1]);
				}
				const returns = extractReturnBefore(content, funcStart);
				methods.push({ name: methodName, params, returns, isServerOnly: false, isClientOnly: false });
			} else {
				methods.push({ name: methodName, params: [], returns: null, isServerOnly: false, isClientOnly: false });
			}
		}
	}

	return {
		fileName,
		namespace,
		context,
		className,
		callable,
		implName,
		explicitMethods,
		constructorParams,
		methods,
	};
}

function generateMethodCall(facade: FacadeInfo, method: FacadeMethod, side: 'server' | 'client'): string {
	const { namespace, callable, className, implName } = facade;
	const { name, params, returns } = method;

	let argIndex = 1;
	const argExpressions: string[] = [];

	// Constructor / source injection
	if (implName) {
		if (namespace === 'Target') {
			// Target methods do not take player source
		} else if (side === 'server') {
			argExpressions.push('source');
		} else {
			// Client-side shared impl methods need the local player's server id
			argExpressions.push('GetPlayerServerId(PlayerId())');
		}
	} else if (callable && className) {
		if (namespace === 'Player') {
			if (side === 'server') {
				argExpressions.push('source');
			}
			// client: no source arg for TSFX:Player()
		} else if (namespace === 'Gang' || namespace === 'Job') {
			argExpressions.push(`coerce(args[${argIndex}])`);
			argIndex++;
		}
		// Framework: no constructor args
	}

	// Method params
	// For impl facades (except Target), the first param is usually `source` which we already injected above
	const effectiveParams = (implName && namespace !== 'Target' && params[0]?.name === 'source')
		? params.slice(1)
		: params;

	for (const param of effectiveParams) {
		const simple = simpleType(param.type);
		if (simple === 'vector3') {
			argExpressions.push(`vector3(coerce(args[${argIndex}]), coerce(args[${argIndex + 1}]), coerce(args[${argIndex + 2}]))`);
			argIndex += 3;
		} else if (simple === 'vector4') {
			argExpressions.push(`vector4(coerce(args[${argIndex}]), coerce(args[${argIndex + 1}]), coerce(args[${argIndex + 2}]), coerce(args[${argIndex + 3}]))`);
			argIndex += 4;
		} else if (isComplexType(param.type)) {
			argExpressions.push('nil --[[complex table arg, pass JSON or edit command]]');
		} else {
			argExpressions.push(`coerce(args[${argIndex}])`);
			argIndex++;
		}
	}

	// Build call expression
	let callExpr = '';
	if (implName) {
		callExpr = `TSFX.${namespace}.${name}(${argExpressions.join(', ')})`;
	} else if (callable && className) {
		if (namespace === 'Player') {
			if (side === 'server') {
				const rest = argExpressions.slice(1).join(', ');
				callExpr = `TSFX:Player(source):${name}(${rest})`;
			} else {
				callExpr = `TSFX:Player():${name}(${argExpressions.join(', ')})`;
			}
		} else if (namespace === 'Framework') {
			callExpr = `TSFX:Framework():${name}(${argExpressions.join(', ')})`;
		} else if (namespace === 'Gang' || namespace === 'Job') {
			const ctorArg = argExpressions[0];
			const rest = argExpressions.slice(1).join(', ');
			callExpr = `TSFX:${namespace}(${ctorArg}):${name}(${rest})`;
		}
	}

	const returnsSelf = returns && (returns.includes('HandleClass') || returns.includes(namespace + 'HandleClass'));
	let lua = '';
	if (returnsSelf || !returns) {
		lua += `        ${callExpr}\n`;
		lua += `        printResult(source, 'OK')`;
	} else {
		lua += `        local result = ${callExpr}\n`;
		lua += `        printResult(source, result)`;
	}

	return lua;
}

function generateCommandsLua(facades: FacadeInfo[], side: 'server' | 'client'): string {
	let lua = `-- Auto-generated TSFX SDK test commands (${side})\n`;
	lua += `-- Regenerated on every link.\n`;
	lua += `-- Usage: /tsfx <namespace> <method> [args...]\n`;
	lua += `--        /tsfx list\n\n`;

	lua += `local function coerce(val)\n`;
	lua += `    local n = tonumber(val)\n`;
	lua += `    if n ~= nil then return n end\n`;
	lua += `    if val == 'true' then return true end\n`;
	lua += `    if val == 'false' then return false end\n`;
	lua += `    if val == 'nil' then return nil end\n`;
	lua += `    return val\n`;
	lua += `end\n\n`;

	lua += `local function printResult(source, result)\n`;
	lua += `    local text\n`;
	lua += `    if type(result) == 'table' then\n`;
	lua += `        text = json.encode(result)\n`;
	lua += `    else\n`;
	lua += `        text = tostring(result)\n`;
	lua += `    end\n`;
	if (side === 'server') {
		lua += `    if source > 0 then\n`;
		lua += `        TriggerClientEvent('chat:addMessage', source, { color = {0, 255, 100}, multiline = true, args = { '[TSFX]', text } })\n`;
		lua += `    else\n`;
		lua += `        print('[TSFX] ' .. text)\n`;
		lua += `    end\n`;
	} else {
		lua += `    TriggerEvent('chat:addMessage', { color = {0, 255, 100}, multiline = true, args = { '[TSFX]', text } })\n`;
	}
	lua += `end\n\n`;

	lua += `local Dispatch = {}\n\n`;

	for (const facade of facades) {
		const validMethods = facade.methods.filter(m => {
			if (side === 'server' && m.isClientOnly) return false;
			if (side === 'client' && m.isServerOnly) return false;
			return true;
		});

		if (validMethods.length === 0) continue;

		lua += `Dispatch['${facade.namespace.toLowerCase()}'] = {\n`;
		for (const method of validMethods) {
			const callCode = generateMethodCall(facade, method, side);
			lua += `    ['${method.name}'] = function(source, args)\n${callCode}\n    end,\n`;
		}
		lua += `}\n\n`;
	}

	lua += `RegisterCommand('tsfx', function(source, args, raw)\n`;
	lua += `    if #args < 1 then\n`;
	if (side === 'server') {
		lua += `        TriggerClientEvent('chat:addMessage', source, { color = {255, 0, 0}, args = { '[TSFX]', 'Usage: /tsfx <namespace> <method> [args...]' } })\n`;
	} else {
		lua += `        TriggerEvent('chat:addMessage', { color = {255, 0, 0}, args = { '[TSFX]', 'Usage: /tsfx <namespace> <method> [args...]' } })\n`;
	}
	lua += `        return\n`;
	lua += `    end\n\n`;

	lua += `    local namespace = args[1]:lower()\n`;
	lua += `    if namespace == 'list' then\n`;
	lua += `        local lines = {}\n`;
	lua += `        for ns, methods in pairs(Dispatch) do\n`;
	lua += `            local names = {}\n`;
	lua += `            for n, _ in pairs(methods) do\n`;
	lua += `                table.insert(names, n)\n`;
	lua += `            end\n`;
	lua += `            table.sort(names)\n`;
	lua += `            table.insert(lines, ns .. ': ' .. table.concat(names, ', '))\n`;
	lua += `        end\n`;
	lua += `        table.sort(lines)\n`;
	lua += `        printResult(source, table.concat(lines, '\\n'))\n`;
	lua += `        return\n`;
	lua += `    end\n\n`;

	lua += `    if #args < 2 then\n`;
	if (side === 'server') {
		lua += `        TriggerClientEvent('chat:addMessage', source, { color = {255, 0, 0}, args = { '[TSFX]', 'Usage: /tsfx <namespace> <method> [args...]' } })\n`;
	} else {
		lua += `        TriggerEvent('chat:addMessage', { color = {255, 0, 0}, args = { '[TSFX]', 'Usage: /tsfx <namespace> <method> [args...]' } })\n`;
	}
	lua += `        return\n`;
	lua += `    end\n\n`;

	lua += `    local method = args[2]\n`;
	lua += `    local methodArgs = {}\n`;
	lua += `    for i = 3, #args do\n`;
	lua += `        table.insert(methodArgs, args[i])\n`;
	lua += `    end\n\n`;

	lua += `    local ns = Dispatch[namespace]\n`;
	lua += `    if not ns then\n`;
	if (side === 'server') {
		lua += `        TriggerClientEvent('chat:addMessage', source, { color = {255, 0, 0}, args = { '[TSFX]', 'Unknown namespace: ' .. namespace } })\n`;
	} else {
		lua += `        TriggerEvent('chat:addMessage', { color = {255, 0, 0}, args = { '[TSFX]', 'Unknown namespace: ' .. namespace } })\n`;
	}
	lua += `        return\n`;
	lua += `    end\n`;

	lua += `    local fn = ns[method]\n`;
	lua += `    if not fn then\n`;
	if (side === 'server') {
		lua += `        TriggerClientEvent('chat:addMessage', source, { color = {255, 0, 0}, args = { '[TSFX]', 'Unknown method: ' .. method .. ' in ' .. namespace } })\n`;
	} else {
		lua += `        TriggerEvent('chat:addMessage', { color = {255, 0, 0}, args = { '[TSFX]', 'Unknown method: ' .. method .. ' in ' .. namespace } })\n`;
	}
	lua += `        return\n`;
	lua += `    end\n\n`;

	lua += `    local ok, err = pcall(function()\n`;
	lua += `        fn(source, methodArgs)\n`;
	lua += `    end)\n`;
	lua += `    if not ok then\n`;
	if (side === 'server') {
		lua += `        TriggerClientEvent('chat:addMessage', source, { color = {255, 0, 0}, args = { '[TSFX]', 'Error: ' .. tostring(err) } })\n`;
	} else {
		lua += `        TriggerEvent('chat:addMessage', { color = {255, 0, 0}, args = { '[TSFX]', 'Error: ' .. tostring(err) } })\n`;
	}
	lua += `    end\n`;
	lua += `end, false)\n`;

	return lua;
}

function generateManifest(): string {
	return `fx_version 'cerulean'
game 'gta5'

author 'TSFX SDK'
description 'Auto-generated test commands for TSFX SDK facades'
version '0.0.1'

dependency 'tsfx_sdk'

shared_scripts {
    '@tsfx_sdk/init.lua'
}

server_scripts {
    'server/commands.lua'
}

client_scripts {
    'client/commands.lua'
}

lua54 'yes'
`;
}

export async function generateTestResource(targetDir: string): Promise<void> {
	const facadesDir = path.join(__dirname, '../resource/facades');
	const files = (await fs.readdir(facadesDir)).filter(f => f.endsWith('.lua') && f !== '_base.lua');

	const facades: FacadeInfo[] = [];
	for (const file of files) {
		const info = parseFacadeFile(path.join(facadesDir, file));
		if (info) facades.push(info);
	}

	await fs.ensureDir(path.join(targetDir, 'server'));
	await fs.ensureDir(path.join(targetDir, 'client'));
	await fs.writeFile(path.join(targetDir, 'fxmanifest.lua'), generateManifest());
	await fs.writeFile(path.join(targetDir, 'server', 'commands.lua'), generateCommandsLua(facades, 'server'));
	await fs.writeFile(path.join(targetDir, 'client', 'commands.lua'), generateCommandsLua(facades, 'client'));
}
