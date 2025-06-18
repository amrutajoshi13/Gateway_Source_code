#!/bin/bash

# Run this inside the root of your git repo
echo "[INFO] Adding .gitkeep to all empty directories..."

# Step 1: Add .gitkeep to all empty directories
find . -type d -empty -not -path "./.git/*" -not -path "./.git" -exec touch {}/.gitkeep \;

# Step 2: Add .gitkeep files to git
git add $(find . -name .gitkeep)

# Step 3: Add all hidden files (except .git directory)
echo "[INFO] Adding hidden files (.*) except .git..."
find . -maxdepth 1 -type f -name ".*" ! -name ".git" -exec git add {} \;

# Optional: Add all hidden files in subdirectories
find . -type f -name ".*" -not -path "./.git/*" -exec git add {} \;

exit 0
