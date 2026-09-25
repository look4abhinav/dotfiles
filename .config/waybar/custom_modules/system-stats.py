#!/usr/bin/env python3
import fcntl
import html
import json
import os
import sys
import tempfile
from pathlib import Path

NORMAL = "#42ff9f"
WARNING = "#f0a040"
CRITICAL = "#e35149"
INFORMATIONAL = "#75f1fa"


def color_for(value, warning=70, critical=90):
    if value >= critical:
        return CRITICAL
    if value >= warning:
        return WARNING
    return NORMAL


def colored(value, color):
    return f"<span color='{color}'>{html.escape(str(value))}</span>"


def state_path():
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR")
    if runtime_dir and os.path.isdir(runtime_dir) and os.access(runtime_dir, os.W_OK):
        directory = Path(runtime_dir)
    else:
        directory = Path("/tmp")
    return directory / ".waybar-system-stats.json"


def read_cpu_samples():
    samples = {}
    with open("/proc/stat", encoding="ascii") as stream:
        for line in stream:
            fields = line.split()
            if not fields:
                continue
            name = fields[0]
            if name != "cpu" and not (name.startswith("cpu") and name[3:].isdigit()):
                continue
            values = [int(value) for value in fields[1:9]]
            samples[name] = (sum(values), values[3] + values[4])
    return samples


def read_previous(path):
    try:
        with path.open(encoding="ascii") as stream:
            data = json.load(stream)
        return {
            name: (int(values[0]), int(values[1]))
            for name, values in data.items()
            if isinstance(values, list) and len(values) == 2
        }
    except (OSError, ValueError, TypeError, json.JSONDecodeError):
        return {}


def write_current(path, samples):
    payload = {name: list(values) for name, values in samples.items()}
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=".waybar-system-stats.", dir=path.parent
    )
    try:
        os.fchmod(descriptor, 0o600)
        with os.fdopen(descriptor, "w", encoding="ascii") as stream:
            json.dump(payload, stream, separators=(",", ":"))
            stream.write("\n")
        os.replace(temporary_name, path)
    except BaseException:
        try:
            os.unlink(temporary_name)
        except FileNotFoundError:
            pass
        raise


def cpu_usage(current, previous):
    usage = {}
    for name, (total, idle) in current.items():
        old = previous.get(name)
        if old is None or total <= old[0]:
            usage[name] = 0.0
            continue
        total_delta = total - old[0]
        idle_delta = max(0, idle - old[1])
        usage[name] = max(
            0.0, min(100.0, (total_delta - idle_delta) * 100.0 / total_delta)
        )
    return usage


def cpu_tooltip():
    path = state_path()
    lock_path = path.with_suffix(".lock")
    with lock_path.open("a+", encoding="ascii") as lock:
        os.chmod(lock_path, 0o600)
        fcntl.flock(lock.fileno(), fcntl.LOCK_EX)
        current = read_cpu_samples()
        previous = read_previous(path)
        usage = cpu_usage(current, previous)
        write_current(path, current)

    overall = usage.get("cpu", 0.0)
    core_names = sorted(
        (name for name in usage if name != "cpu"), key=lambda name: int(name[3:])
    )
    core_count = max(1, len(core_names))
    try:
        with open("/proc/loadavg", encoding="ascii") as stream:
            load = float(stream.read().split()[0])
    except (OSError, IndexError, ValueError):
        load = 0.0
    load_percentage = min(100.0, load * 100.0 / core_count)
    lines = [
        "<b>CPU</b>",
        f"Total: {colored(f'{overall:.0f}%', color_for(overall))}",
        f"Load: {colored(f'{load:.2f}', color_for(load_percentage))}",
    ]
    lines.extend(
        f"Core {name[3:]}: {colored(f'{usage[name]:.0f}%', color_for(usage[name]))}"
        for name in core_names
    )
    state = []
    if overall >= 90:
        state.append("critical")
    elif overall >= 70:
        state.append("warning")
    return {
        "text": f"{overall:.0f}%",
        "tooltip": "\n".join(lines),
        "class": state,
        "percentage": round(overall),
    }


def read_meminfo():
    values = {}
    with open("/proc/meminfo", encoding="ascii") as stream:
        for line in stream:
            key, separator, value = line.partition(":")
            if not separator:
                continue
            fields = value.split()
            if fields:
                values[key] = int(fields[0])
    return values


def percentage(used, total):
    if total <= 0:
        return 0.0
    return max(0.0, min(100.0, used * 100.0 / total))


def gibibytes(kibibytes):
    return kibibytes / 1024.0 / 1024.0


def memory_tooltip():
    values = read_meminfo()
    total = values["MemTotal"]
    available = values.get("MemAvailable", 0)
    used = max(0, total - available)
    ram_percentage = percentage(used, total)
    swap_total = values.get("SwapTotal", 0)
    swap_free = values.get("SwapFree", 0)
    swap_used = max(0, swap_total - swap_free)
    swap_percentage = percentage(swap_used, swap_total)
    ram_line = (
        f"RAM: {colored(f'{ram_percentage:.0f}%', color_for(ram_percentage))} "
        f"({gibibytes(used):.1f}G/{gibibytes(total):.1f}G used)"
    )
    if swap_total > 0:
        swap_line = (
            f"Swap: {colored(f'{swap_percentage:.0f}%', color_for(swap_percentage, 50, 80))} "
            f"({gibibytes(swap_used):.1f}G/{gibibytes(swap_total):.1f}G used)"
        )
    else:
        swap_line = f"Swap: {colored('Off', INFORMATIONAL)}"
    state = []
    if ram_percentage >= 90:
        state.append("critical")
    elif ram_percentage >= 70:
        state.append("warning")
    return {
        "text": f"{ram_percentage:.0f}%",
        "tooltip": f"<b>Memory</b>\n{ram_line}\n{swap_line}",
        "class": state,
        "percentage": round(ram_percentage),
    }


def fallback(kind):
    if kind == "cpu":
        return {"text": "0%", "tooltip": "<b>CPU</b>\nUnavailable", "class": []}
    return {"text": "0%", "tooltip": "<b>Memory</b>\nUnavailable", "class": []}


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in {"cpu", "memory"}:
        return 2
    try:
        result = cpu_tooltip() if sys.argv[1] == "cpu" else memory_tooltip()
    except (OSError, KeyError, TypeError, ValueError, json.JSONDecodeError):
        result = fallback(sys.argv[1])
    print(json.dumps(result, separators=(",", ":")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
