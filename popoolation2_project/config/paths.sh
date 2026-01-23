#!/usr/bin/env bash
set -euo pipefail

# repo 根目录：默认是 config 的上一级
BASE="${BASE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# 需要老师改的路径（你先填你自己的 wright 路径）
FASTQDIR="${FASTQDIR:-/mnt/data/wright/home/u8021786/dart_all}"
REF="${REF:-$BASE/ref/Amel_HAv3.1.fna}"

# scratch（没有的话也可以改成 /tmp 或 $BASE/scratch）
SCR="${SCR:-/mnt/data/wright/home/scratch/${USER}/popoolation2_project}"

# conda env 名称
CONDA_ENV="${CONDA_ENV:-popoolation2}"

# PoPoolation2 jar（默认按你现在 conda 的结构推导）
P2JAR="${P2JAR:-$CONDA_PREFIX/share/popoolation2-1.201-0/mpileup2sync.jar}"
