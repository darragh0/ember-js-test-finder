"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.activate = activate;
exports.deactivate = deactivate;
const vscode = __importStar(require("vscode"));
const child_process_1 = require("child_process");
const path = __importStar(require("path"));
const util_1 = require("util");
const execAsync = (0, util_1.promisify)(child_process_1.exec);
const ERROR_MESSAGES = {
    1: 'No test files found for this file',
    2: 'No file provided',
    3: 'Not a TypeScript or JavaScript file',
    4: 'File is not in an Ember app/ directory',
    5: 'Unknown file type',
    6: 'Cannot find Ember project root (looking for app/ and tests/ directories)',
    7: 'Missing app/ or tests/ directory in Ember project'
};
function activate(context) {
    const disposable = vscode.commands.registerCommand('ember-js-test-finder.findTests', async () => {
        const activeEditor = vscode.window.activeTextEditor;
        if (!activeEditor) {
            vscode.window.showErrorMessage('No active file');
            return;
        }
        const currentFilePath = activeEditor.document.fileName;
        const scriptPath = path.join(context.extensionPath, 'find-all-tests.sh');
        try {
            const { stdout, stderr } = await execAsync(`bash "${scriptPath}" "${currentFilePath}"`);
            if (stdout.trim()) {
                const testFiles = stdout.trim().split(',');
                if (testFiles.length === 1) {
                    await openFile(testFiles[0]);
                }
                else {
                    const quickPickItems = testFiles.map(filePath => ({
                        label: path.basename(filePath),
                        description: getRelativePath(filePath),
                        filePath: filePath
                    }));
                    const selected = await vscode.window.showQuickPick(quickPickItems, {
                        placeHolder: 'Select a test file to open',
                        matchOnDescription: true
                    });
                    if (selected) {
                        await openFile(selected.filePath);
                    }
                }
            }
        }
        catch (error) {
            const exitCode = error.code;
            if (exitCode && ERROR_MESSAGES[exitCode]) {
                vscode.window.showErrorMessage(ERROR_MESSAGES[exitCode]);
            }
            else {
                vscode.window.showErrorMessage(`Error finding tests: ${error.message}`);
            }
        }
    });
    context.subscriptions.push(disposable);
}
async function openFile(filePath) {
    try {
        const document = await vscode.workspace.openTextDocument(filePath);
        await vscode.window.showTextDocument(document);
    }
    catch (error) {
        vscode.window.showErrorMessage(`Failed to open file: ${error.message}`);
    }
}
function getRelativePath(filePath) {
    const workspaceFolders = vscode.workspace.workspaceFolders;
    if (workspaceFolders && workspaceFolders.length > 0) {
        const workspaceRoot = workspaceFolders[0].uri.fsPath;
        if (filePath.startsWith(workspaceRoot)) {
            return path.relative(workspaceRoot, filePath);
        }
    }
    // Try to get a relative path from the project name
    const parts = filePath.split(path.sep);
    const appIndex = parts.indexOf('app');
    const testsIndex = parts.indexOf('tests');
    if (appIndex > 0) {
        // Return path from the project directory
        return parts.slice(appIndex - 1).join(path.sep);
    }
    else if (testsIndex > 0) {
        // Return path from the project directory
        return parts.slice(testsIndex - 1).join(path.sep);
    }
    return filePath;
}
function deactivate() { }
//# sourceMappingURL=extension.js.map