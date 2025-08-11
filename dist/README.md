# Ember JS Test Finder Extension

A VS Code extension to quickly find and open test files for Ember.js projects

## Features

- Press `Cmd+Shift+T` (Mac) or `Ctrl+Shift+T` (Windows/Linux) to find tests for the current file
- Shows a QuickPick modal with all available test files
- Single test file opens immediately
- Multiple test files show a selection list
- Error messages for unsupported files

## Installation

### Quick Install (Recommended)

Run the following and then restart VS Code / Cursor

```bash
cd ~/test-finder && ./install.sh
```

### Manual Installation

Run the following and then restart VS Code / Cursor

```bash
cd ~/test-finder && npm install && npm run compile && cp -r ~/test-finder ~/.vscode/extensions/ember-js-test-finder
```

### Uninstall

```bash
rm -rf ~/.vscode/extensions/ember-js-test-finder
```

## Usage

1. Open any JavaScript or TypeScript file in your Ember `app/` directory
2. Press `Cmd+Shift+T` (Mac) or `Ctrl+Shift+T` (Windows/Linux)
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

### Both Integration and Unit Tests
- Components, helpers, and modifiers can have both test types
- The extension will find all existing test files

## How It Works

The extension:
1. Detects your Ember project root by finding the `app/` and `tests/` directories
2. Determines the file type based on its location in the `app/` directory
3. Looks for corresponding test files following Ember conventions
4. Supports both `.js` and `.ts` files

## Error Messages

- **No test files found**: The file has no associated test files
- **Not a TypeScript or JavaScript file**: Only `.ts` and `.js` files are supported
- **Not in an Ember app/ directory**: File must be in an Ember `app/` directory
- **Cannot find Ember project root**: Could not locate both `app/` and `tests/` directories
- **Missing app/ or tests/ directory**: Ember project structure is incomplete

## Development

To modify the extension:

1. Edit files in the `src/` directory
2. Run `npm run compile` to rebuild
3. Reload VS Code to test changes

## Customization

To change the keyboard shortcut:

1. Open VS Code Settings (`Cmd+,` or `Ctrl+,`)
2. Search for "Keyboard Shortcuts"
3. Search for "Find Tests for Current File"
4. Click the pencil icon to edit the shortcut
