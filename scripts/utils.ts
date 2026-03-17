import { red, yellow, green, blue, cyan, dim } from 'yoctocolors';

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
