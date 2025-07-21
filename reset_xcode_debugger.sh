#!/bin/bash

# Reset Xcode Debugger State for ZenlyticStyleEditor
# This script removes user-specific debugger settings that might cause unwanted stops

echo "🧹 Resetting Xcode debugger state for ZenlyticStyleEditor..."

# Find and remove user state files
find . -name "*.xcuserstate" -delete
find . -name "UserInterfaceState.xcuserstate" -delete

# Remove derived data for this project
DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
PROJECT_NAME="ZenlyticStyleEditor"

if [ -d "$DERIVED_DATA_PATH" ]; then
    echo "🗑️  Cleaning derived data..."
    find "$DERIVED_DATA_PATH" -name "*$PROJECT_NAME*" -type d -exec rm -rf {} + 2>/dev/null || true
fi

echo "✅ Debugger state reset complete!"
echo ""
echo "Next steps:"
echo "1. Close Xcode completely"
echo "2. Reopen the project"
echo "3. Run the app - it should launch without stopping at breakpoints"
echo ""
echo "If you still get unwanted stops:"
echo "- Go to Debug → Breakpoints → Remove All Breakpoints"
echo "- Or press Cmd+Y to toggle breakpoints off" 