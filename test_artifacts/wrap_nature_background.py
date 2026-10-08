"""Wrap Scaffold `body:` expressions in NatureBackground.wrap(...).

Uses balanced-paren matching so exactly one closing paren is added.
Safe to run repeatedly (skips already-wrapped bodies).
"""
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

FILES = [
    "lib/features/admin/screens/admin_login_screen.dart",
    "lib/features/admin/screens/admin_panel_screen.dart",
    "lib/features/auth/screens/forgot_password_screen.dart",
    "lib/features/auth/screens/login_screen.dart",
    "lib/features/auth/screens/signup_screen.dart",
    "lib/features/bookings/screens/bookings_screen.dart",
    "lib/features/bookings/screens/booking_detail_screen.dart",
    "lib/features/bookings/screens/booking_form_screen.dart",
    "lib/features/destinations/screens/destination_detail_screen.dart",
    "lib/features/guides/screens/guide_detail_screen.dart",
    "lib/features/hotels/screens/hotel_detail_screen.dart",
    "lib/features/packages/screens/packages_screen.dart",
    "lib/features/payments/screens/payment_screen.dart",
    "lib/features/profile/screens/profile_screen.dart",
    "lib/features/transports/screens/transports_screen.dart",
]

IMPORT_LINE = "import 'package:comfygo/core/widgets/widgets.dart';"


def match_paren(src, open_idx):
    depth = 0
    i = open_idx
    n = len(src)
    in_str = None
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
        elif c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return -1


def match_expr_end(src, start):
    """Return exclusive end index of the value expression starting at `start`.

    Stops at a top-level `,` `)` `;` (not consumed), skipping nested
    parens/brackets/braces and string literals. Handles multi-line ternaries.
    """
    i = start
    n = len(src)
    depth = 0
    in_str = None
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
        elif c in "([{":
            depth += 1
        elif c in ")]}":
            if depth == 0:
                return i
            depth -= 1
        elif c == "," and depth == 0:
            return i
        elif c == ";" and depth == 0:
            return i
        i += 1
    return -1


def transform(src):
    out = src
    inserts = []
    for m in re.finditer(r"\bbody:\s*", src):
        start = m.end()
        if out[start:].startswith("NatureBackground.wrap"):
            continue
        end = match_expr_end(src, start)
        if end <= start:
            continue
        expr = src[start:end]
        if "(" not in expr:
            continue  # plain identifier/variable reference
        inserts.append((start, end))
    if not inserts:
        return None
    res = out
    for start, end in reversed(inserts):
        expr = res[start:end]
        res = (
            res[:start]
            + "NatureBackground.wrap(child: "
            + expr.strip()
            + ")"
            + res[end:]
        )

    # ensure import
    if "core/widgets/widgets.dart" not in res and "nature_background" not in res:
        lines = res.split("\n")
        idx = [i for i, ln in enumerate(lines) if ln.startswith("import ")]
        if idx:
            lines.insert(idx[-1] + 1, IMPORT_LINE)
        else:
            lines.insert(0, IMPORT_LINE + "\n")
        res = "\n".join(lines)
    return res


def main():
    changed = []
    for path in FILES:
        with open(path, encoding="utf-8") as f:
            src = f.read()
        new = transform(src)
        if new and new != src:
            with open(path, "w", encoding="utf-8", newline="") as f:
                f.write(new)
            changed.append(path)
    print("changed:", len(changed))
    for c in changed:
        print("  ", c)


if __name__ == "__main__":
    main()
