# Ember JS Test Finder Extension

[![Marketplace Version](https://img.shields.io/visual-studio-marketplace/v/darragh0.ember-js-test-finder?logo=visual-studio-code&label=version)](https://marketplace.visualstudio.com/items?itemName=darragh0.ember-js-test-finder)
[![Installs](https://img.shields.io/visual-studio-marketplace/i/darragh0.ember-js-test-finder?logo=visual-studio-code)](https://marketplace.visualstudio.com/items?itemName=darragh0.ember-js-test-finder)
[![Rating](https://img.shields.io/visual-studio-marketplace/r/darragh0.ember-js-test-finder?logo=visual-studio-code)](https://marketplace.visualstudio.com/items?itemName=darragh0.ember-js-test-finder)

A VS Code extension to quickly find and open test files for Ember.js projects

## Features

- Hold `Cmd` (Mac) or `Ctrl` (Win/Linux) and double tap `T` to find tests for the current file
- A Single test file opens immediately
- Multiple test files show a selection dialog

## Usage

1. Open any JavaScript or TypeScript file in your Ember `app/` directory
2. Press `Cmd+T, Cmd+T` (Mac) or `Ctrl+T, Ctrl+T` (Windows/Linux)
3. Select a test file from the list (if multiple exist)
4. The test file opens in the editor

## Supported File Types

The extension follows Ember's standard test conventions:

### Integration Tests (typically in `tests/integration/`)

- **Components** - Primary test type for components
- **Helpers** - Primary test type for helpers
- **Modifiers** - Primary test type for modifiers

### Unit Tests (typically in `tests/unit/`)

- **Models** - Data model tests
- **Services** - Service layer tests
- **Routes** - Route handler tests
- **Controllers** - Controller logic tests
- **Adapters** - Data adapter tests
- **Serializers** - Data serialization tests
- **Mixins** - Mixin functionality tests
- **Initializers** - App initializer tests
- **Instance Initializers** - Instance initializer tests
- **Transforms** - Data transform tests
- **Utils** - Utility function tests

## Error Messages

- **No test files found**: The file has no associated test files
- **Not a TypeScript or JavaScript file**: Only `.ts` and `.js` files are supported
- **Not in an Ember app/ directory**: File must be in an Ember `app/` directory
- **Cannot find Ember project root**: Could not locate both `app/` and `tests/` directories
- **Missing app/ or tests/ directory**: Ember project structure is incomplete

## Development

To modify the extension:

1. Edit files in the `src/` directory
2. Reinstall to auto-compile and deploy (see [Installation](#installation))
3. Reload your editor window (Command Palette → "Developer: Reload Window")

## Customization

To change the keyboard shortcut:

1. Open VS Code Settings (`Cmd+,` or `Ctrl+,`)
2. Search for "Keyboard Shortcuts"
3. Search for "Find Tests for Current File"
4. Click the pencil icon to edit the shortcut

## Manual Installation

Only needed if you want to force a reinstall locally. After the extension is installed from the marketplace, you can run the bundled installer from the extension folder.

- **Find the installed extension folder**

  - VS Code: Command Palette → "Extensions: Open Extensions Folder" (or `~/.vscode/extensions`)
  - Cursor: Command Palette → "Extensions: Open Extensions Folder" (or `~/.cursor/extensions`)

- **From a terminal, navigate to the latest installed version and run the installer**

  VS Code:

  ```bash
  EXT_DIR=$(ls -d ~/.vscode/extensions/darragh0.ember-js-test-finder-* | sort -V | tail -1)
  cd "$EXT_DIR"
  ./install.sh --code
  ```

  Cursor:

  ```bash
  EXT_DIR=$(ls -d ~/.cursor/extensions/darragh0.ember-js-test-finder-* | sort -V | tail -1)
  cd "$EXT_DIR"
  ./install.sh --cursor
  ```

- **What the installer does**
  - Detects changes and compiles if needed
  - Copies the fresh build into your editor’s extensions folder
  - Ensures `find-all-tests.sh` is executable
  - Prompts you to reload your editor
