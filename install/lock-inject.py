#!/usr/bin/env python3
"""Inject custom.lock config into shell.json.

Adds the lock plugin, disables stock omarchy.lock, and tracks clone source.
Run by the lock install module after copying shell.json.
"""

import json
import sys

path = sys.argv[1] if len(sys.argv) > 1 else \
    __import__('os').path.expanduser("~/.config/omarchy/shell.json")

with open(path) as f:
    cfg = json.load(f)

# Add custom.lock as a loaded service plugin
plugins = cfg.setdefault("plugins", [])
if not any(p.get("id") == "custom.lock" for p in plugins):
    plugins.append({"id": "custom.lock"})

# Disable the stock lock screen
disabled = cfg.setdefault("disabledPlugins", [])
if "omarchy.lock" not in disabled:
    disabled.append("omarchy.lock")

# Track custom.lock as a clone (so omarchy knows it's a fork)
restores = cfg.setdefault("cloneSourceRestores", [])
if "custom.lock" not in restores:
    restores.append("custom.lock")

with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")

print(f"  Injected custom.lock config into {path}")
