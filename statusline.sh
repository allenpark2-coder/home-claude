#!/usr/bin/env python3
import json, sys, time

data = json.load(sys.stdin)

def make_bar(pct, width=10):
    filled = int((pct or 0) / 100 * width)
    return '█' * filled + '░' * (width - filled)

# Context
ctx_pct = int(data.get('context_window', {}).get('used_percentage', 0) or 0)
ctx_bar = make_bar(ctx_pct)

# 5-hour usage
parts = [f"Context {ctx_bar} {ctx_pct}%"]

rate = data.get('rate_limits', {})
five_h = rate.get('five_hour', {}) if rate else {}
if five_h:
    usage_pct = five_h.get('used_percentage', 0) or 0
    resets_at = five_h.get('resets_at')
    usage_bar = make_bar(usage_pct)
    reset_str = ""
    if resets_at:
        remaining = int(resets_at - time.time())
        if remaining > 0:
            h, m = divmod(remaining // 60, 60)
            reset_str = f" (resets in {h}h {m:02d}m)" if h else f" (resets in {m}m)"
    parts.append(f"Usage {usage_bar} {int(usage_pct)}%{reset_str}")

print("  │  ".join(parts))
