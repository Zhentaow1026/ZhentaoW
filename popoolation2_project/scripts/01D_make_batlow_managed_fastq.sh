#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../config/paths.sh"

mkdir -p "$BASE/meta"

cat > "$BASE/meta/batlow_managed_map.tsv" <<'EOF'
4675556	BatlowBM7
4675568	BatlowBM8
4675579	BatlowBM1
4675580	BatlowBM9
4675591	BatlowBM2
4675592	BatlowBM10
4675603	BatlowBM3
4675604	BatlowBM11
4675615	BatlowBM4
4675616	BatlowBM12
4675627	BatlowBM5
4675628	BatlowBM13
4675639	BatlowBM6
4675640	BatlowBM14
EOF

# results=14
awk '{print $2}' "$BASE/meta/batlow_managed_map.tsv" | sort -u > "$BASE/meta/batlow_managed_genotypes.txt"
wc -l "$BASE/meta/batlow_managed_genotypes.txt"
cat "$BASE/meta/batlow_managed_genotypes.txt"

OUT="$BASE/fastq_by_genotype/batlow_managed"
mkdir -p "$OUT"

while read -r GENO; do
  echo "Merging $GENO ..."
  ids=$(awk -v g="$GENO" '$2==g{print $1}' "$BASE/meta/batlow_managed_map.tsv")

  cat $(for id in $ids; do echo "$FASTQDIR/${id}.FASTQ.gz"; done) > "$OUT/${GENO}.FASTQ.gz"

  gzip -t "$OUT/${GENO}.FASTQ.gz"
done < "$BASE/meta/batlow_managed_genotypes.txt"

ls -lh "$OUT" | head
