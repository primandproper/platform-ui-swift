#!/usr/bin/env bash
# Print the Swift files format and lint own.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo Package.swift
find Sources Tests -name '*.swift' -not -path '*/.build/*' | sort
