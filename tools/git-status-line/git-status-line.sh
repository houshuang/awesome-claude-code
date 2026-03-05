#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract current directory from JSON
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model_name=$(echo "$input" | jq -r '.model.display_name // .model.id')
context_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | xargs printf "%.0f")

# Change to the current directory
cd "$current_dir" 2>/dev/null || exit 1

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    printf "%s in %s | %s%% ctx" "$model_name" "$(basename "$current_dir")" "$context_pct"
    exit 0
fi

# Get git information
branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || "unknown")
git_status=$(git status --porcelain 2>/dev/null)

# Count different types of changes
modified=0
staged=0
untracked=0
deleted=0

while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        status_code="${line:0:2}"
        case "$status_code" in
            " M"|" T") ((modified++)) ;;     # Modified in working tree
            "M "|"A "|"D "|"R "|"C "|"T ") ((staged++)) ;;  # Staged changes
            "MM"|"AM"|"AD"|"MD") ((staged++)); ((modified++)) ;;  # Both staged and modified
            "??") ((untracked++)) ;;         # Untracked files
            " D") ((deleted++)) ;;           # Deleted in working tree
            "D ") ((staged++)) ;;            # Deleted and staged
            "DD"|"AU"|"UD"|"UA"|"DU"|"AA"|"UU") ((modified++)) ;;  # Merge conflicts
        esac
    fi
done <<< "$git_status"

# Build status indicators
status_parts=()

if [[ $staged -gt 0 ]]; then
    status_parts+=("+$staged")  # Staged changes
fi

if [[ $modified -gt 0 ]]; then
    status_parts+=("~$modified")  # Modified files
fi

if [[ $deleted -gt 0 ]]; then
    status_parts+=("-$deleted")  # Deleted files
fi

if [[ $untracked -gt 0 ]]; then
    status_parts+=("?$untracked")  # Untracked files
fi

# Check if we're ahead/behind remote
ahead_behind=""
upstream=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
if [[ -n "$upstream" ]]; then
    ahead=$(git rev-list --count HEAD ^"$upstream" 2>/dev/null)
    behind=$(git rev-list --count "$upstream" ^HEAD 2>/dev/null)

    if [[ $ahead -gt 0 && $behind -gt 0 ]]; then
        ahead_behind=" ↕$ahead/$behind"
    elif [[ $ahead -gt 0 ]]; then
        ahead_behind=" ↑$ahead"
    elif [[ $behind -gt 0 ]]; then
        ahead_behind=" ↓$behind"
    fi
fi

# Format the final output
if [[ ${#status_parts[@]} -gt 0 ]]; then
    status_str=" [$(IFS=' '; echo "${status_parts[*]}")]"
else
    status_str=" ✓"  # Checkmark for clean
fi

printf "%s on %s%s%s in %s | %s%% ctx" \
    "$model_name" \
    "$branch" \
    "$status_str" \
    "$ahead_behind" \
    "$(basename "$current_dir")" \
    "$context_pct"
