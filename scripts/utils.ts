/** biome-ignore-all lint/complexity/noStaticOnlyClass: Classes created for easier organization */
import fs from 'fs-extra';
import { blue, cyan, dim, green, red, yellow } from 'yoctocolors';

export class Logger {
    static info(message: string, detail?: string): void {
        console.log(blue('ℹ'), message, detail ? dim(detail) : '');
    }

    static success(message: string, detail?: string): void {
        console.log(green('✓'), message, detail ? dim(detail) : '');
    }

    static warn(message: string, detail?: string): void {
        console.log(yellow('⚠'), message, detail ? dim(detail) : '');
    }

    static error(message: string, detail?: string): void {
        console.error(red('✗'), message, detail ? dim(detail) : '');
    }

    static step(message: string): void {
        console.log(cyan('→'), message);
    }
}

export interface Config {
    serverPath: string | string[];
    resourcePath: string;
    category?: string;
    autoRestart?: boolean;
}

export class ConfigLoader {
    static async load(configPath: string): Promise<Config> {
        if (!await fs.pathExists(configPath)) {
            Logger.error('.dev.config.json not found');
            Logger.info('Create on based on example.dev.config.json');
            process.exit(1);
        }

        const content = await fs.readFile(configPath, 'utf-8');

        return JSON.parse(content) as Config;
    }
}
