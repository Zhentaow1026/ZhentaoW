#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../config/paths.sh"

mkdir -p "$BASE/meta"

cat > "$BASE/meta/young_managed_map.tsv" <<'EOF'
4675553	YoungBM7
4675565	YoungBM8
4675576	YoungBM1
4675577	YoungBM9
4675588	YoungBM2
4675589	YoungBM10
4675600	YoungBM3
4675612	YoungBM4
4675624	YoungBM5
4675636	YoungBM6
4675648	YoungBM7
4675652	YoungBM8
4675654	YoungBM1
4675655	YoungBM9
4675657	YoungBM2
4675658	YoungBM10
4675660	YoungBM3
4675663	YoungBM4
4675666	YoungBM5
4675669	YoungBM6
EOF

# results=10
awk '{print $2}' "$BASE/meta/young_managed_map.tsv" | sort -u > "$BASE/meta/young_managed_genotypes.txt"
wc -l "$BASE/meta/young_managed_genotypes.txt"
cat "$BASE/meta/young_managed_genotypes.txt"

OUT="$BASE/fastq_by_genotype/young_managed"
mkdir -p "$OUT"

while read -r GENO; do
  echo "Merging $GENO ..."
  ids=$(awk -v g="$GENO" '$2==g{print $1}' "$BASE/meta/young_managed_map.tsv")

  cat $(for id in $ids; do echo "$FASTQDIR/${id}.FASTQ.gz"; done) > "$OUT/${GENO}.FASTQ.gz"

  gzip -t "$OUT/${GENO}.FASTQ.gz"
done < "$BASE/meta/young_managed_genotypes.txt"

ls -lh "$OUT" | head
