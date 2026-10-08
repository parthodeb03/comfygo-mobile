"""Convert OneUIColors.<mode-dependent> constants into AppColors.x(context).

- Skips theme definition files (they define the palette).
- Strips any `const` keyword whose creation expression contains a replaced
  color (const expressions cannot call functions).
- Inserts an import for app_colors.dart when needed.
"""
import os
import posixpath
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

SKIP_FILES = {
    "lib/core/theme/one_ui_colors.dart",
    "lib/core/theme/one_ui_theme.dart",
    "lib/core/theme/app_colors.dart",
    "lib/core/widgets/one_ui_app_bar.dart",  # already theme-aware
}

MAP = {
    "textPrimaryLight": "textPrimary",
    "textPrimaryDark": "textPrimary",
    "textSecondaryLight": "textSecondary",
    "textSecondaryDark": "textSecondary",
    "textHintLight": "textHint",
    "textHintDark": "textHint",
    "backgroundLight": "background",
    "backgroundDark": "background",
    "surfaceLight": "surface",
    "surfaceDark": "surface",
    "surfaceVariantLight": "surfaceVariant",
    "surfaceVariantDark": "surfaceVariant",
    "inputFillLight": "inputFill",
    "dividerLight": "divider",
    "dividerDark": "divider",
    "primaryLight": "primary",
    "primaryDark": "primary",
    "primarySoft": "primarySoft",
    "primaryVariantLight": "primaryVariant",
    "secondaryLight": "secondary",
    "secondaryDark": "secondary",
    "tertiaryLight": "tertiary",
    "tertiaryDark": "tertiary",
}

TARGET_RE = re.compile(r"OneUIColors\.(\w+)")


def match_delim(src, open_idx):
    """Return index just past the delimiter group starting at open_idx."""
    pairs = {"(": ")", "[": "]", "{": "}"}
    opener = src[open_idx]
    closer = pairs[opener]
    depth = 0
    i = open_idx
    n = len(src)
    in_str = None  # quote char
    while i < n:
        c = src[i]
        if in_str:
            if c == "\\":
                i += 2
                continue
            if c == in_str:
                in_str = None
            i += 1
            continue
        if c in "'\"":
            in_str = c
        elif c == opener:
            depth += 1
        elif c == closer:
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return n


def const_spans(src):
    spans = []
    for m in re.finditer(r"\bconst\b", src):
        i = m.end()
        n = len(src)
        while i < n and src[i] in " \t\n\r":
            i += 1
        # skip optional type args like <Widget>
        if i < n and src[i] == "<":
            depth = 0
            while i < n:
                if src[i] == "<":
                    depth += 1
                elif src[i] == ">":
                    depth -= 1
                    if depth == 0:
                        i += 1
                        break
                i += 1
            while i < n and src[i] in " \t\n\r":
                i += 1
        # skip identifier (e.g. const Text(...) or const EdgeInsets.all(...))
        if i < n and (src[i].isalpha() or src[i] == "_"):
            while i < n and (src[i].isalnum() or src[i] in "_.$"):
                i += 1
            while i < n and src[i] in " \t\n\r":
                i += 1
        if i < n and src[i] in "([{":
            end = match_delim(src, i)
            spans.append((m.start(), end))
    return spans


def transform(path, src):
    targets = [m for m in TARGET_RE.finditer(src) if m.group(1) in MAP]
    if not targets:
        return None
    spans = const_spans(src)
    to_remove = set()
    for t in targets:
        for start, end in spans:
            if start < t.start() < end:
                to_remove.add(start)
    # mutate from the end so offsets stay valid
    edits = []
    for t in targets:
        repl = f"AppColors.{MAP[t.group(1)]}(context)"
        edits.append((t.start(), t.end(), repl))
    for start in to_remove:
        edits.append((start, start + len("const"), ""))
    edits.sort(key=lambda e: e[0], reverse=True)
    out = src
    for s, e, repl in edits:
        out = out[:s] + repl + out[e:]

    # insert import if the file does not already import app_colors
    if "app_colors.dart" not in out:
        imp = "import '{rel}';"
        lines = out.split("\n")
        import_idx = [i for i, ln in enumerate(lines) if ln.startswith("import ")]
        this_dir = posixpath.dirname(path.replace(os.sep, "/"))
        rel = posixpath.relpath("lib/core/theme/app_colors.dart", this_dir)
        rel = rel.replace(os.sep, "/")
        stmt = imp.format(rel=rel)
        # prefer placing right before an import of theme.dart (alphabetically before)
        insert_at = (import_idx[-1] + 1) if import_idx else 0
        for i in import_idx:
            if "theme/theme.dart" in lines[i] or "one_ui" in lines[i]:
                insert_at = i
                break
        lines.insert(insert_at, stmt)
        out = "\n".join(lines)
    return out


def main():
    changed = []
    for root, _dirs, files in os.walk("lib"):
        for fn in files:
            if not fn.endswith(".dart"):
                continue
            path = os.path.join(root, fn).replace(os.sep, "/")
            if path in SKIP_FILES:
                continue
            with open(path, encoding="utf-8") as f:
                src = f.read()
            new = transform(path, src)
            if new is not None and new != src:
                with open(path, "w", encoding="utf-8", newline="") as f:
                    f.write(new)
                changed.append(path)
    print(f"changed {len(changed)} files:")
    for c in changed:
        print("  ", c)


if __name__ == "__main__":
    main()
