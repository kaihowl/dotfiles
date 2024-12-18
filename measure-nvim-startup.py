#!/usr/bin/env python3

import subprocess
import tempfile
import sys
from pathlib import Path
import sqlite3

DB_FILE = "startuptimes.sqlite3"


def determine_git():
    revision = subprocess.check_output("git rev-parse HEAD", shell=True).strip()
    idx = subprocess.check_output(
        "git rev-list HEAD..origin/master --count", shell=True
    ).strip()
    return {
        "revision": revision,
        "idx": idx,
    }


def canonicalize_line(line: str) -> str:
    line = line.strip()
    SOURCING = "sourcing "
    REQUIRE = "require('"
    if line.startswith(SOURCING):
        path = line[len(SOURCING) :]
        return Path(path).name
    elif line.startswith(REQUIRE):
        return line[len(REQUIRE) : -2]
    else:
        raise Exception(f"Cannot canonicalize '{line}'")


def get_measurements(fname: str):
    with open(fname) as f:
        for line in f.readlines():
            try:
                (times, sourcelines) = line.split(":", maxsplit=1)
                times = times.split()
                if len(times) != 3:
                    continue
                clock = float(times[0])
                self_and_sourced = float(times[1])
                self = float(times[2])
                name = canonicalize_line(sourcelines)
                yield {
                    "clock": clock,
                    "self_and_sourced": self_and_sourced,
                    "self": self,
                    "name": name,
                }
            except ValueError:  # not enough values to unpack / not a time
                continue


def measure():
    header = determine_git()
    for i in range(0, 10):
        fname = tempfile.mktemp()
        subprocess.check_call(
            f"nvim --headless --startuptime {fname} +qall", shell=True
        )
        for m in get_measurements(fname):
            m.update(header)
            yield m


if __name__ == "__main__":
    with sqlite3.connect(DB_FILE) as db:
        db.execute(
            "create table if not exists startuplog(revision, idx, clock, self_and_sourced, self, name)",
        )
        for m in measure():
            db.execute(
                "insert into startuplog values(:revision, :idx, :clock, :self_and_sourced, :self, :name)",
                m,
            )
