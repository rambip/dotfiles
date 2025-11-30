#!/bin/bash

# Script to identify and remove unused executable scripts in chezmoi dotfiles
# This script accounts for chezmoi's naming convention where executable_*.sh files
# are managed and potentially renamed

CHEZMOI_DIR="/var/home/rambip/.local/share/chezmoi"
TEMP_DIR="/tmp/chezmoi-scripts-check"
UNUSED_FILE="$CHEZMOI_DIR/unused-scripts.txt"

# Create temporary directory
mkdir -p "$TEMP_DIR"

echo "Analyzing scripts in chezmoi dotfiles..."

echo "# Unused Scripts" > "$UNUSED_FILE"
echo "# Generated on $(date)" >> "$UNUSED_FILE"
echo "" >> "$UNUSED_FILE"

cd "$CHEZMOI_DIR"

# Find all executable scripts managed by chezmoi
find . -type f -name "executable_*.sh" | sort > "$TEMP_DIR/all-scripts.txt"

echo "Found $(wc -l < "$TEMP_DIR/all-scripts.txt") scripts to analyze"

echo "Checking each script for usage..."

echo "" >> "$UNUSED_FILE"
echo "## Potentially Unused Scripts" >> "$UNUSED_FILE"
echo "" >> "$UNUSED_FILE"

UNUSED_COUNT=0

while IFS= read -r script_path; do
    # Extract just the filename
    script_name=$(basename "$script_path")
    
    # The actual script name without "executable_" prefix
    actual_name="${script_name#executable_}"
    
    # Remove .sh extension for matching
    actual_name_noext="${actual_name%.sh}"
    
    # Look for references to the script in config files
    # Check for both the full path and just the script name
    references=""
    
    # First check for the full path with executable_ prefix
    if grep -r -l -F "$script_path" . 2>/dev/null | grep -v "check-unused-scripts.sh" | grep -v "unused-scripts.txt" > /dev/null; then
        references="$(grep -r -l -F \"$script_path\" . 2>/dev/null | grep -v \"check-unused-scripts.sh\" | grep -v \"unused-scripts.txt\")"
    fi
    
    # If no references found, check for just the script name with executable_ prefix
    if [ -z "$references" ] && grep -r -l -F "$script_name" . 2>/dev/null | grep -v "check-unused-scripts.sh" | grep -v "unused-scripts.txt" > /dev/null; then
        references="$(grep -r -l -F \"$script_name\" . 2>/dev/null | grep -v \"check-unused-scripts.sh\" | grep -v \"unused-scripts.txt\")"
    fi
    
    # If no references found, check for the actual name (without executable_ prefix)
    if [ -z "$references" ] && grep -r -l -F "$actual_name" . 2>/dev/null | grep -v "check-unused-scripts.sh" | grep -v "unused-scripts.txt" > /dev/null; then
        references="$(grep -r -l -F \"$actual_name\" . 2>/dev/null | grep -v \"check-unused-scripts.sh\" | grep -v \"unused-scripts.txt\")"
    fi
    
    # If no references found, check for just the name without .sh extension
    if [ -z "$references" ] && grep -r -l -F "$actual_name_noext" . 2>/dev/null | grep -v "check-unused-scripts.sh" | grep -v "unused-scripts.txt" > /dev/null; then
        references="$(grep -r -l -F \"$actual_name_noext\" . 2>/dev/null | grep -v \"check-unused-scripts.sh\" | grep -v \"unused-scripts.txt\")"
    fi
    
    # Special case: check input.conf and utils.conf which contain most script references
    if [ -z "$references" ]; then
        # Look for script usage in key config files
        if grep -q "$script_path" ./dot_config/hypr/input.conf 2>/dev/null || \
           grep -q "$script_path" ./dot_config/hypr/utils.conf 2>/dev/null || \
           grep -q "$script_name" ./dot_config/hypr/input.conf 2>/dev/null || \
           grep -q "$script_name" ./dot_config/hypr/utils.conf 2>/dev/null || \
           grep -q "$actual_name" ./dot_config/hypr/input.conf 2>/dev/null || \
           grep -q "$actual_name" ./dot_config/hypr/utils.conf 2>/dev/null || \
           grep -q "$actual_name_noext" ./dot_config/hypr/input.conf 2>/dev/null || \
           grep -q "$actual_name_noext" ./dot_config/hypr/utils.conf 2>/dev/null; then
            references="./dot_config/hypr/input.conf or ./dot_config/hypr/utils.conf"
        fi
    fi
    
    # If still no references, it's likely unused
    if [ -z "$references" ]; then
        echo "- $script_path" >> "$UNUSED_FILE"
        echo "  (No references found in config files)" >> "$UNUSED_FILE"
        UNUSED_COUNT=$((UNUSED_COUNT + 1))
    fi

done < "$TEMP_DIR/all-scripts.txt"

echo "" >> "$UNUSED_FILE"
echo "Total potentially unused scripts: $UNUSED_COUNT" >> "$UNUSED_FILE"

echo "Analysis complete. Results saved to $UNUSED_FILE"
echo "Review the list before removing any scripts."

echo "To remove unused scripts, run:"
echo "grep '^- ' \"$UNUSED_FILE\" | sed 's/- .//' | while read -r script; do rm \"$CHEZMOI_DIR/$script\" && echo \"Removed $script\"; done"

echo "Cleanup temporary files..."
rm -rf "$TEMP_DIR"

exit 0