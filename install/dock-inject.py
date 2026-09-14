#!/usr/bin/env python3
"""Inject custom.dock config into shell.json.

Adds the dock as a loaded service plugin. Unlike custom.lock, the dock isn't
a clone of a first-party plugin, so there's no disabledPlugins/
cloneSourceRestores bookkeeping — just a plugins[] entry.
Run by the dock install module after copying the plugin files.
"""

import json
import sys

path = sys.argv[1] if len(sys.argv) > 1 else \
    __import__('os').path.expanduser("~/.config/omarchy/shell.json")

with open(path) as f:
    cfg = json.load(f)

plugins = cfg.setdefault("plugins", [])
if not any(p.get("id") == "custom.dock" for p in plugins):
    plugins.append({"id": "custom.dock"})

with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")

print(f"  Injected custom.dock config into {path}")
