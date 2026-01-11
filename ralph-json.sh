#!/bin/bash
# Convert markdown PRD to JSON for querying

if [ ! -f "prd.md" ]; then
    echo "Error: prd.md not found in current directory"
    exit 1
fi

echo "Converting prd.md to prd.json..."

python3 << 'PYTHON'
import re
import json
import sys

try:
    with open('prd.md', 'r') as f:
        content = f.read()
except Exception as e:
    print(f"Error reading prd.md: {e}", file=sys.stderr)
    sys.exit(1)

stories = []
story_id = 0

# Match tasks with optional acceptance criteria
# Pattern: - [ ] or - [x] followed by task content, then optional AC lines
lines = content.split('\n')
current_story = None

for line in lines:
    # Check for task line
    task_match = re.match(r'^- \[([ x])\] (.+)$', line)
    if task_match:
        # Save previous story if exists
        if current_story:
            stories.append(current_story)

        story_id += 1
        checked = task_match.group(1) == 'x'
        title = task_match.group(2).strip()

        current_story = {
            "id": f"US-{story_id:03d}",
            "title": title,
            "acceptanceCriteria": [],
            "passes": checked
        }

    # Check for AC line (indented under task)
    elif current_story and re.match(r'^\s+- AC\d+:', line):
        ac_text = re.sub(r'^\s+- AC\d+:\s*', '', line)
        current_story["acceptanceCriteria"].append(ac_text)

# Don't forget last story
if current_story:
    stories.append(current_story)

# Add default AC if none found
for story in stories:
    if not story["acceptanceCriteria"]:
        story["acceptanceCriteria"] = ["Tests pass"]

result = {"userStories": stories}

try:
    with open('prd.json', 'w') as f:
        json.dump(result, f, indent=2)
except Exception as e:
    print(f"Error writing prd.json: {e}", file=sys.stderr)
    sys.exit(1)

passing = sum(1 for s in stories if s['passes'])
total = len(stories)
remaining = total - passing

print(f"Created prd.json with {total} stories")
print(f"  Passing: {passing}")
print(f"  Remaining: {remaining}")
PYTHON
