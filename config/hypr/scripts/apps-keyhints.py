#!/usr/bin/env python3

import json
import os
import shlex
import subprocess
from typing import Any, Dict, List

MOD_MAP = {
    64: "Super",
    32: "Hyper",
    16: "Meta",
    8: "Alt",
    4: "Ctrl",
    2: "CapsLock",
    1: "Shift",
}

KEY_MAP = {
    "period": ".",
    "comma": ",",
    "slash": "/",
    "semicolon": ";",
    "quote": "'",
    "backslash": "\\",
    "minus": "-",
    "equal": "=",
    "bracketright": "]",
    "bracketleft": "[",
    "mouse:272": "Left Click",
    "mouse:273": "Right Click",
    "mouse:274": "Middle Click",
    "mouse:275": "Scroll Up",
    "mouse:276": "Scroll Down",
}


def get_binds() -> List[Dict[str, Any]]:
    try:
        out = subprocess.run(
            ["hyprctl", "binds", "-j"], capture_output=True, text=True, check=True
        )
        return json.loads(out.stdout)
    except Exception as e:
        print(f"Error: {e}", flush=True)
        return []


def map_mod(modmask: int) -> str:
    names = [
        name for bit, name in sorted(MOD_MAP.items(), reverse=True) if modmask & bit
    ]
    return " + ".join(names)


def map_key(key: str) -> str:
    if not key:
        return ""
    k = key.lower()
    return KEY_MAP.get(k, key)


def short_arg(arg: str) -> str:
    try:
        parts = shlex.split(arg)
    except Exception:
        return arg or ""
    if not parts:
        return ""
    parts[0] = os.path.basename(parts[0])
    return " ".join(parts)


def format_binds(binds: List[Dict[str, Any]]) -> List[str]:
    lines: List[str] = []
    for b in binds:
        key = map_key(b.get("key", "") or "")
        mods = map_mod(b.get("modmask", 0))

        if mods and key:
            full_key = f"{mods} + {key}"
        elif mods:
            full_key = mods
        else:
            full_key = key

        desc = (b.get("description") or "").strip()
        if not desc:
            desc = short_arg(b.get("arg", "") or "")

        dispatcher = (b.get("dispatcher") or "").strip()
        arg = (b.get("arg") or "").strip()
        repeat = "true" if b.get("repeat") else "false"

        display = f"{full_key} ::: {desc}".strip()
        lines.append(f"{display}\t{dispatcher}\t{arg}\t{repeat}")
    return lines


def main() -> None:
    binds = get_binds()
    for ln in format_binds(binds):
        print(ln)


if __name__ == "__main__":
    main()
