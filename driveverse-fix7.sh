#!/usr/bin/env bash
set -euo pipefail

FILE="DriveVerse/LiveActivity/LiveActivityController.swift"

python3 - <<'PY'
from pathlib import Path

p = Path("DriveVerse/LiveActivity/LiveActivityController.swift")
s = p.read_text()

old = '''        let completed = words[..<index].map(\.original).joined()
        let active = words[index].original
        let remaining = words[(index + 1)...].map(\.original).joined()'''

new = '''        let timedText = words.map(\.original).joined()
        guard timedText == fallback else {
            // A provider may omit untimed suffixes, punctuation, or spacing
            // from its word timeline. Prefer the complete lyric line over a
            // truncated word-level animation.
            return ("", fallback, "", false, 0, 0)
        }

        let completed = words[..<index].map(\.original).joined()
        let active = words[index].original
        let remaining = words[(index + 1)...].map(\.original).joined()'''

if old not in s:
    raise SystemExit("ERROR: target block not found; source may have changed")

p.write_text(s.replace(old, new, 1))
print("✅ Preserved complete lyric fallback when word timing is incomplete")
PY

git diff --check
echo
echo "Changed lines:"
grep -n -A12 'let timedText = words.map' "$FILE"
echo
echo "✅ Validation passed. Review the lines above, then commit and push."
