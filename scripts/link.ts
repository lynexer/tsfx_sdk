import { execSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import fs from 'fs-extra';
import createSpinner from 'yocto-spinner';
import { generateTestResource } from './generate-test-resource.js';
import { ConfigLoader, Logger } from './utils';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

class LinkCommand {
    private targetDir: string;
    private category: string;
    private autoRestart: boolean;
    private serverName: string;

    constructor(targetDir: string, category: string, autoRestart: boolean, serverName: string) {
        this.targetDir = targetDir;
        this.category = category;
        this.autoRestart = autoRestart;
        this.serverName = serverName;
    }

    private async bundleResource(): Promise<void> {
        const name = 'tsfx_sdk';
        const spinner = createSpinner({ text: `Linking ${name}` }).start();

        try {
            const categoryFolder = path.join(this.targetDir, `[${this.category}]`);

            await fs.ensureDir(categoryFolder);

            const src = path.join(__dirname, '../resource');
            const dest = path.join(categoryFolder, name);

            await fs.copy(src, dest, { overwrite: true });
            await fs.remove(path.join(dest, 'package.json'));

            spinner.success(`Linked ${name} -> [${this.category}]/${name}`);
        } catch (error) {
            spinner.error(`Failed to link ${name}`);
            throw error;
        }
    }

    private async bundleTestResource(): Promise<void> {
        const name = 'tsfx_sdk_test';
        const spinner = createSpinner({ text: `Generating ${name}` }).start();

        try {
            const categoryFolder = path.join(this.targetDir, `[${this.category}]`);
            const dest = path.join(categoryFolder, name);

            await generateTestResource(dest);

            spinner.success(`Generated ${name} -> [${this.category}]/${name}`);
        } catch (error) {
            spinner.error(`Failed to generate ${name}`);
            throw error;
        }
    }

    private async restartServer(): Promise<void> {
        if (!this.autoRestart) return;

        const spinner = createSpinner({ text: 'Restarting server' }).start();

        try {
            execSync(`rcon restart ${this.category}`, { stdio: 'pipe' });
            spinner.success(`Restarted [${this.category}]`);
        } catch {
            spinner.warning('Could not restart server (is rcon configured?)');
        }
    }

    async execute(): Promise<void> {
        Logger.step(`Starting link process for ${this.serverName}...`);

        await this.bundleResource();
        await this.bundleTestResource();

        Logger.success(`Resources linked to [${this.category}]\n`);

        await this.restartServer();
    }
}

async function main() {
    const configPath = path.resolve(__dirname, '../.dev.config.json');
    const config = await ConfigLoader.load(configPath);

    const servers = Array.isArray(config.serverPath) ? config.serverPath : [config.serverPath];

    for (const server of servers) {
        const targetDir = path.resolve(server, config.resourcePath);
        const command = new LinkCommand(
            targetDir,
            config.category || 'tsfx',
            config.autoRestart ?? false,
            path.basename(server)
        );

        await command.execute();
    }
}

main().catch((err) => {
    Logger.error('Link failed', err.message);
    process.exit(1);
});
