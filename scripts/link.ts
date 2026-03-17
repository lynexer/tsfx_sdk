import { execSync } from 'child_process';
import fs from 'fs-extra';
import path from "path";
import { fileURLToPath } from "url";
import createSpinner from 'yocto-spinner';
import { ConfigLoader, Logger } from './utils';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

class LinkCommand {
    private targetDir: string;
    private category: string;
    private autoRestart: boolean;

    constructor(targetDir: string, category: string, autoRestart: boolean) {
        this.targetDir = targetDir;
        this.category = category;
        this.autoRestart = autoRestart;
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
        Logger.step('Starting link process...');

        await this.bundleResource();

        Logger.success(`Resource linked to [${this.category}]\n`);

        await this.restartServer();
    }
}

async function main() {
    const configPath = path.resolve(__dirname, '../.dev.config.json');
    const config = await ConfigLoader.load(configPath);

    const command = new LinkCommand(
        config.resourcePath,
        config.category || 'tsfx',
        config.autoRestart ?? true
    );

    await command.execute();
}

main().catch(err => {
    Logger.error('Link failed', err.message);
    process.exit(1);
});
