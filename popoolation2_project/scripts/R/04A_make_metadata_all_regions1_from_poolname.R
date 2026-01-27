
bamlist <- "meta/all_regions1_bams_order.txt"
out_dir <- "results"
out_file <- file.path(out_dir, "pool_metadata_all_regions1.csv")

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

bams <- readLines(bamlist)
bams <- bams[nzchar(bams)]

# pool name get from BAM file
pool <- sub("\\.bam$", "", basename(bams))

# Parse region from prefix: Young* vs Batlow*
region <- ifelse(grepl("^Young", pool), "Young",
                 ifelse(grepl("^Batlow", pool), "Batlow", NA))


# YoungBF1 -----Young + B + F -----feral
# YoungBM1 ----Young + B + M --- managed
# BatlowBF1 ----Batlow + B + F ----feral
# BatlowBM1 ----Batlow + B + M ----managed
feral <- ifelse(grepl("^[A-Za-z]+B[Ff]", pool), "feral",
                ifelse(grepl("^[A-Za-z]+B[Mm]", pool), "managed", NA))

# check
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

write.csv(metadata, out_file, row.names = FALSE, quote = FALSE)
cat("Wrote:", out_file, "\n")
