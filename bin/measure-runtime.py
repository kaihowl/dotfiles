#!/usr/bin/env python3

import subprocess
import time
import argparse
import sys

parser = argparse.ArgumentParser()
parser.add_argument('--expected-ms', type=int)
parser.add_argument('-n', '--repeat', type=int, default=10)
parser.add_argument('command', nargs=argparse.REMAINDER)
args = parser.parse_args()

timings = []
for i in range(0, args.repeat):
    start = time.time_ns()
    subprocess.check_call(args.command)
    end = time.time_ns()
    timings.append((end - start)/10**6)

min_measurements = min(timings)
median_measurements = sorted(timings)[len(timings) // 2]
max_measurements = max(timings)

print("min in {} runs was: {} ms".format(args.repeat, min_measurements))
print("median in {} runs was: {} ms".format(args.repeat, median_measurements))
print("max in {} runs was: {} ms".format(args.repeat, max_measurements))

if args.expected_ms and min_measurements > args.expected_ms:
    print("Expected was: {} ms".format(args.expected_ms))
    sys.exit(1)
