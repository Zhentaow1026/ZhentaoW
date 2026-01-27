#!/usr/bin/env bash
set -euo pipefail

# repo 根目录：默认是 config 的上一级; 老师只需要做到一点：他运行脚本时是在这个仓库里，且 config/paths.sh 还在 config 目录（保持你给的结构），这行就自动正确。
BASE="${BASE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# 需要老师改的路径（你先填你自己的 wright 路径）
FASTQDIR="${FASTQDIR:-/mnt/data/wright/home/u8021786/dart_all}"
REF="${REF:-$BASE/ref/Amel_HAv3.1.fna}"

# scratch
SCR="${SCR:-/mnt/data/wright/home/scratch/${USER}/popoolation2_project}"

# conda env 名称
CONDA_ENV="${CONDA_ENV:-popoolation2}"

# PoPoolation2 jar（默认按你现在 conda 的结构推导）; 这是我自己设置的 P2JAR 你应该需要根据你电脑上的conda进行修改
P2JAR="${P2JAR:-$CONDA_PREFIX/share/popoolation2-1.201-0/mpileup2sync.jar}"

# # results dir (repo local; safe for GitHub)
RESULTS="${RESULTS:-$BASE/results}"
mkdir -p "$RESULTS"
