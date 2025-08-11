import { exec } from "child_process";
import * as path from "path";
import { promisify } from "util";
import * as vscode from "vscode";

const execAsync = promisify(exec);

interface TestFileItem extends vscode.QuickPickItem {
  filePath: string;
}

const ERROR_MESSAGES: { [key: number]: string } = {
  1: "No test files found for this file",
  2: "No file provided",
  3: "Not a TypeScript or JavaScript file",
  4: "File is not in an Ember app/ directory",
  5: "Unknown file type",
  6: "Cannot find Ember project root (looking for app/ and tests/ directories)",
  7: "Missing app/ or tests/ directory in Ember project",
};

export function activate(context: vscode.ExtensionContext) {
  // Extension activated

  const disposable = vscode.commands.registerCommand(
    "ember-js-test-finder.findTests",
    async () => {
      const activeEditor = vscode.window.activeTextEditor;

      if (!activeEditor) {
        showTransientNotification("No active file");
        return;
      }

      const currentFilePath = activeEditor.document.fileName;
      const scriptPath = path.join(context.extensionPath, "find-all-tests.sh");

      try {
        const { stdout, stderr } = await execAsync(
          `bash "${scriptPath}" "${currentFilePath}"`
        );

        if (stdout.trim()) {
          const testFiles = stdout.trim().split(",");

          if (testFiles.length === 1) {
            await openFile(testFiles[0]);
          } else {
            const quickPickItems: TestFileItem[] = testFiles.map(
              (filePath) => ({
                label: path.basename(filePath),
                description: getRelativePath(filePath),
                filePath: filePath,
              })
            );

            const selected = await vscode.window.showQuickPick(quickPickItems, {
              placeHolder: "Select a test file to open",
              matchOnDescription: true,
            });

            if (selected) {
              await openFile(selected.filePath);
            }
          }
        }
      } catch (error: any) {
        const exitCode = error.code;

        if (exitCode && ERROR_MESSAGES[exitCode]) {
          showTransientNotification(`${ERROR_MESSAGES[exitCode]}`);
        } else {
          showTransientNotification(`Error finding tests: ${error.message}`);
        }
      }
    }
  );

  context.subscriptions.push(disposable);
}

async function openFile(filePath: string) {
  try {
    const document = await vscode.workspace.openTextDocument(filePath);
    await vscode.window.showTextDocument(document);
  } catch (error: any) {
    showTransientNotification(`Failed to open file: ${error.message}`);
  }
}

function getRelativePath(filePath: string): string {
  const workspaceFolders = vscode.workspace.workspaceFolders;
  if (workspaceFolders && workspaceFolders.length > 0) {
    const workspaceRoot = workspaceFolders[0].uri.fsPath;
    if (filePath.startsWith(workspaceRoot)) {
      return path.relative(workspaceRoot, filePath);
    }
  }

  // Try to get a relative path from the project name
  const parts = filePath.split(path.sep);
  const appIndex = parts.indexOf("app");
  const testsIndex = parts.indexOf("tests");

  if (appIndex > 0) {
    // Return path from the project directory
    return parts.slice(appIndex - 1).join(path.sep);
  } else if (testsIndex > 0) {
    // Return path from the project directory
    return parts.slice(testsIndex - 1).join(path.sep);
  }

  return filePath;
}

export function deactivate() {}

function showTransientNotification(
  message: string,
  durationMs: number = 4000
): void {
  void vscode.window.showErrorMessage(message);
  setTimeout(() => {
    void vscode.commands.executeCommand("workbench.action.closeMessages");
  }, durationMs);
}
