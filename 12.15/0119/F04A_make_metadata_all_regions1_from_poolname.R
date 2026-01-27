# Generate metadata for adonis2 from BAM order list (robust: parse from pool name)

bamlist <- "/mnt/data/wright/home/u8021786/popoolation2_project/meta/all_regions1_bams_order.txt"
out_dir <- "/mnt/data/wright/home/u8021786/popoolation2_project/results"
out_file <- file.path(out_dir, "pool_metadata_all_regions1.csv")

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

bams <- readLines(bamlist)
bams <- bams[nzchar(bams)]

# pool name from BAM filename
pool <- sub("\\.bam$", "", basename(bams))

# Parse region from prefix: Young* vs Batlow*
region <- ifelse(grepl("^Young", pool), "Young",
                 ifelse(grepl("^Batlow", pool), "Batlow", NA))

# Parse feral/managed from the "F" or "M" after the prefix:
# YoungBF1 -> Young + B + F -> feral
# YoungBM1 -> Young + B + M -> managed
# BatlowBF1 -> Batlow + B + F -> feral
# BatlowBM1 -> Batlow + B + M -> managed
feral <- ifelse(grepl("^[A-Za-z]+B[Ff]", pool), "feral",
                ifelse(grepl("^[A-Za-z]+B[Mm]", pool), "managed", NA))

# sanity check: any NA means parsing failed
if (any(is.na(region)) || any(is.na(feral))) {
  bad <- pool[is.na(region) | is.na(feral)]
  stop("Failed to parse region/feral for: ", paste(bad, collapse = ", "))
}

metadata <- data.frame(
  pool   = pool,
  region = factor(region, levels = c("Young", "Batlow")),
  feral  = factor(feral,  levels = c("feral", "managed")),
  bam    = bams,
  stringsAsFactors = FALSE
)

# quick table check printed to console
print(table(metadata$region, metadata$feral))

write.csv(metadata, out_file, row.names = FALSE, quote = FALSE)
cat("Wrote:", out_file, "\n")
