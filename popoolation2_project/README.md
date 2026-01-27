# population2_project

PoPoolation2-based pooled sequencing analysis pipeline.

This project processes pooled FASTQ data from four groups and performs:

mapping → mpileup → sync generation

population distance (FST + PERMANOVA)

allele frequency difference & selection statistics

## Sample groups

Samples are divided into four groups:

young_feral

young_managed

batlow_feral

batlow_managed

## Overall workflow

总结下

## Part 1 — FASTQ to multi-population sync

### 1. Configure paths

Edit `config/paths.sh`:

Main variables:
- `FASTQDIR`: directory containing the raw fastq files named like `4675551.FASTQ.gz`
- `REF`: reference genome fasta (`ref/Amel_HAv3.1.fna`)
- `SCR`: directory
- `CONDA_ENV`: conda env name (`popoolation2`)
- `P2JAR`: path to `mpileup2sync.jar` (optional; if empty, scripts may infer from `$CONDA_PREFIX`)

### 2. Merge FASTQs by genotype

Run:
```bash
bash scripts/01A_make_young_feral_fastq.sh
bash scripts/01B_make_young_managed_fastq.sh
bash scripts/01C_make_batlow_feral_fastq.sh
bash scripts/01D_make_batlow_managed_fastq.sh
```

### 3. Mapping with BWA and samtools using SLURM arrays
Each array task maps one genotype FASTQ:
•	bwa aln -> .sai
•	bwa samse -> .sam
•	samtools view -q 20 filter
•	samtools sort -> .bam
•	samtools index -> .bam.bai
•	copy BAM/BAI back to $BASE/map/<group>/

Submit mapping jobs:
```
sbatch scripts/02A_map_young_feral_array.sbatch
sbatch scripts/02B_map_young_managed_array.sbatch
sbatch scripts/02C_map_batlow_feral_array.sbatch
sbatch scripts/02D_map_batlow_managed_array.sbatch
```

### 4. Generate sync files

#### 4.1 Young populations sync
sbatch scripts/03A_make_sync_young_all.sbatch

Output: sync/young_all.sync

#### 4.2 Batlow populations sync (with exclusions)
> drop two samples, BF1 and BF12

sbatch scripts/03A_make_sync_young_all.sbatch

Output: sync/young_all.sync

#### 4.3 All regions combined sync
> The order of BAMs passed to samtools mpileup defines the population order in the .sync file.
Defined by:
meta/all_regions1_bams_order.txt

Final order in all_regions1.sync:
young_feral → young_managed → batlow_feral(excludes BF1 and BF12) → batlow_managed

## Part 2-Distance matrices and PERMANOVA

### 04A Create metadata table

### 04B Compute FST distance matrices

### 04C PERMANOVA (adonis2 analysis)

## Part 3— Two-population PoPoolation2 analysis

### Overview of 2-population workflow

## Batlow region analysis

### Input files

### Step 1 Allele frequency difference

### Step 2 FST per SNP

### Step 3 Sliding window FST

### Step 4 Fisher’s exact test

### Coverage inspection (Batlow)

#### Extract coverage

#### Plot coverage

## Young region analysis

### Input files

### Coverage inspection (Young)

#### Extract coverage

#### Plot coverage

## Notes and important details
