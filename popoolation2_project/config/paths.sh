#!/usr/bin/env bash
set -euo pipefail

# repo root
BASE="${BASE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# It needs to be adjusted according to your computer or server
FASTQDIR="${FASTQDIR:-/mnt/data/wright/home/u8021786/dart_all}"
REF="${REF:-$BASE/ref/Amel_HAv3.1.fna}"

# scratch
SCR="${SCR:-/mnt/data/wright/home/scratch/${USER}/popoolation2_project}"

# conda env
CONDA_ENV="${CONDA_ENV:-popoolation2}"

# PoPoolation2 jar, it needs to be adjusted according to your computer or server
P2JAR="${P2JAR:-$CONDA_PREFIX/share/popoolation2-1.201-0/mpileup2sync.jar}"

# results
RESULTS="${RESULTS:-$BASE/results}"
mkdir -p "$RESULTS"
