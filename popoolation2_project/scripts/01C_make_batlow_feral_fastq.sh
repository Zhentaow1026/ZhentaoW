#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../config/paths.sh"

mkdir -p "$BASE/meta"

cat > "$BASE/meta/batlow_feral_map.tsv" <<'EOF'
4675554	BatlowBF5
4675555	BatlowBF13
4675566	BatlowBF6
4675567	BatlowBF14
4675578	BatlowBF7
4675590	BatlowBF8
4675601	BatlowBF1
4675602	BatlowBF9
4675613	BatlowBF2
4675614	BatlowBF10
4675625	BatlowBF3
4675626	BatlowBF11
4675637	BatlowBF4
4675638	BatlowBF12
4675661	BatlowBF1
4675664	BatlowBF2
4675667	BatlowBF3
4675670	BatlowBF4
EOF

# results=14
awk '{print $2}' "$BASE/meta/batlow_feral_map.tsv" | sort -u > "$BASE/meta/batlow_feral_genotypes.txt"
wc -l "$BASE/meta/batlow_feral_genotypes.txt"
cat "$BASE/meta/batlow_feral_genotypes.txt"

OUT="$BASE/fastq_by_genotype/batlow_feral"
mkdir -p "$OUT"

while read -r GENO; do
  echo "Merging $GENO ..."
  ids=$(awk -v g="$GENO" '$2==g{print $1}' "$BASE/meta/batlow_feral_map.tsv")

  cat $(for id in $ids; do echo "$FASTQDIR/${id}.FASTQ.gz"; done) > "$OUT/${GENO}.FASTQ.gz"

  gzip -t "$OUT/${GENO}.FASTQ.gz"
done < "$BASE/meta/batlow_feral_genotypes.txt"

ls -lh "$OUT" | head
