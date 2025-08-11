#!/bin/bash

# Install script for Ember JS Test Finder Extension

RED='\033[38;2;255;90;95m'      # Bright coral red
GRN='\033[38;2;80;250;123m'     # Bright mint green
BLU='\033[38;2;139;233;253m'    # Bright sky blue
YLW='\033[38;2;255;214;102m'    # Bright golden yellow
CYN='\033[38;2;98;182;194m'     # Soft cyan
MAG='\033[38;2;255;121;198m'    # Bright pink
PRP='\033[38;2;189;147;249m'    # Bright purple
ORG='\033[38;2;255;184;108m'    # Bright orange
BLD='\033[1m'
DIM='\033[2m'
RES='\033[0m'

show_help() {
    echo -e "${BLD}${MAG}Ember JS Test Finder Extension Installer${RES}"
    echo
    echo -e "${BLD}${CYN}Description:${RES}"
    echo "  Installs the Ember JS Test Finder VS Code/Cursor extension that allows you to"
    echo "  quickly find and open test files for Ember.js components using the"
    echo -e "  keyboard shortcut ${MAG}${BLD}Cmd+T, Cmd+T${RES} (Mac) or ${MAG}${BLD}Ctrl+T, Ctrl+T${RES} (Win/Linux)"
    echo
    echo -e "${BLD}${CYN}Usage:${RES}"
    echo -e "  ${DIM}${MAG}./install.sh ${RES}${MAG}--cursor${RES}      Install to Cursor"
    echo -e "  ${DIM}${MAG}./install.sh ${RES}${MAG}--code${RES}        Install to VS Code"
    echo -e "  ${DIM}${MAG}./install.sh ${RES}${MAG}--help/-h${RES}     Show this help message"
    echo
    echo -e "${BLD}${CYN}Supported Editors:${RES}"
    echo -e "  ${BLU}•${RES} VS Code"
    echo -e "  ${BLU}•${RES} Cursor"
    echo
    echo -e "${BLD}${CYN}Uninstall:${RES}"
    echo -e "  VS Code:  ${ORG}rm -rf ~/.vscode/extensions/local.ember-js-test-finder-*${RES}"
    echo -e "  Cursor:   ${ORG}rm -rf ~/.cursor/extensions/local.ember-js-test-finder-*${RES}"
    echo
    exit 0
}

show_usage_and_exit() {
    echo -e "${BLD}${CYN}usage:${RES} ${DIM}${MAG}./install.sh${RES} [${MAG}--cursor${RES} | ${MAG}--code${RES} | ${MAG}--help/-h${RES}]"
    exit 1
}

PUBLISHER=$(node -p "require('./package.json').publisher || 'local'" 2>/dev/null || echo "local")
NAME=$(node -p "require('./package.json').name || 'ember-js-test-finder'" 2>/dev/null || echo "ember-js-test-finder")
VERSION=$(node -p "require('./package.json').version || '1.0.0'" 2>/dev/null || echo "1.0.0")
EXT_DIR_NAME="${PUBLISHER}.${NAME}-${VERSION}"

if [ $# -eq 0 ]; then
    echo -e "${RED}${BLD}err:${RES} missing required argument\n"
    show_usage_and_exit
fi

TARGET=""
case "$1" in
    -h|--help)
        show_help ;;
    --cursor)
        TARGET="cursor"
        EXTENSIONS_DIR="$HOME/.cursor/extensions"
        EDITOR_NAME="Cursor" ;;
    --code)
        TARGET="code"
        EXTENSIONS_DIR="$HOME/.vscode/extensions"
        EDITOR_NAME="VS Code" ;;
    *)
        echo -e "${RED}${BLD}err:${RES} unknown option: ${MAG}$1${RES}\n"
        show_usage_and_exit ;;
esac

echo -e "Selected: ${MAG}$EDITOR_NAME${RES}\n"

if [ ! -d "node_modules" ]; then
    echo -e "${YLW}Installing dependencies...${RES}"
    npm install
    if [ $? -ne 0 ]; then
        echo -e "${RED}${BLD}Failed to install dependencies${RES}"
        exit 1
    fi
    echo -e "${GRN}✓ Dependencies installed${RES}"
    echo
fi

# Check if compilation is needed
needs_compile=false

if [ ! -d "out" ]; then
    needs_compile=true
else
    # Check if any source file is newer than the compiled output
    newest_src=$(find src -type f -name "*.ts" -exec stat -f "%m" {} \; 2>/dev/null | sort -n | tail -1 || find src -type f -name "*.ts" -exec stat -c "%Y" {} \; 2>/dev/null | sort -n | tail -1)
    newest_out=$(find out -type f -name "*.js" -exec stat -f "%m" {} \; 2>/dev/null | sort -n | tail -1 || find out -type f -name "*.js" -exec stat -c "%Y" {} \; 2>/dev/null | sort -n | tail -1)

    if [ -n "$newest_src" ] && [ -n "$newest_out" ]; then
        if [ "$newest_src" -gt "$newest_out" ]; then
            needs_compile=true
            echo -e "${YLW}Source files have changed since last compile${RES}"
        fi
    fi
fi

if [ "$needs_compile" = true ]; then
    echo -e "${YLW}Compiling TypeScript...${RES}"
    npm run compile
    if [ $? -ne 0 ]; then
        echo -e "${RED}${BLD}Failed to compile TypeScript${RES}"
        exit 1
    fi
    echo -e "${GRN}✓ TypeScript compiled${RES}"
    echo
fi

if [ ! -d "$EXTENSIONS_DIR" ]; then
    echo -e "$EDITOR_NAME extensions directory not found. Creating ..."
    mkdir -p "$EXTENSIONS_DIR"
fi

# Cleanup stale installs and ensure correct folder naming: publisher.name-version
WRONG_DIR="$EXTENSIONS_DIR/$NAME"
if [ -d "$WRONG_DIR" ]; then
    echo -e "Removing old installation at ${ORG}$WRONG_DIR${RES}"
    rm -rf "$WRONG_DIR"
fi

# Remove any previous versions for this publisher/name to avoid duplicates
for d in "$EXTENSIONS_DIR/${PUBLISHER}.${NAME}-"*; do
    if [ -d "$d" ]; then
        echo -e "Removing previous version ${ORG}$d${RES}"
        rm -rf "$d"
    fi
done

EXT_DIR="$EXTENSIONS_DIR/$EXT_DIR_NAME"
echo -e "Installing extension to: ${ORG}$EXT_DIR${RES}"

mkdir -p "$EXT_DIR"
echo -e "Copying extension files ..."
cp -r out "$EXT_DIR/"
cp package.json "$EXT_DIR/"
cp find-all-tests.sh "$EXT_DIR/"
cp README.md "$EXT_DIR/"

chmod +x "$EXT_DIR/find-all-tests.sh"

echo
echo -e "${GRN}Extension installed successfully to $EDITOR_NAME!${RES}"
echo ""
echo -e "${BLD}${CYN}To use the extension:${RES}"
echo -e "  ${BLU}1.${RES} Restart $EDITOR_NAME (or run: ${MAG}Developer: Reload Window${RES})"
echo -e "  ${BLU}2.${RES} Open any JavaScript or TypeScript file in your Ember ${ORG}app/${RES} directory"
echo -e "  ${BLU}3.${RES} Press ${MAG}${BLD}Cmd+T, Cmd+T${RES} (Mac) or ${MAG}${BLD}Ctrl+T, Ctrl+T${RES} (Windows/Linux)"
echo ""
echo -e "${BLD}${CYN}To uninstall:${RES}"
echo -e "  ${ORG}rm -rf $EXT_DIR${RES}"
echo
