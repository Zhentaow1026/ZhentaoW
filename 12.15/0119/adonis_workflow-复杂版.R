#!/usr/bin/env Rscript

# ---- force user library path on Windows ----
user_lib <- file.path(Sys.getenv("USERPROFILE"), "Documents", "R", "win-library", "4.5")
if (dir.exists(user_lib)) {
  .libPaths(c(user_lib, .libPaths()))
}

suppressPackageStartupMessages({
  library(vegan)
})


stop2 <- function(...) stop(paste0(...), call. = FALSE)

args <- commandArgs(trailingOnly = TRUE)
dist_file <- ifelse(length(args) >= 1, args[1], "distance_matrix_cailliez.csv")
meta_file <- ifelse(length(args) >= 2, args[2], "pool_metadata_all_regions1.csv")
out_prefix <- ifelse(length(args) >= 3, args[3], "adonis")

cat("Distance file:", dist_file, "\n")
cat("Metadata file (optional):", meta_file, "\n")
cat("Output prefix:", out_prefix, "\n\n")

# -----------------------------
# read distance matrix
# -----------------------------
dist_df <- read.csv(dist_file, row.names = 1, check.names = FALSE)
if (nrow(dist_df) != ncol(dist_df)) stop2("Distance matrix is not square.")
dist_mat <- as.matrix(dist_df)
mode(dist_mat) <- "numeric"

# checks
sym_diff <- max(abs(dist_mat - t(dist_mat)), na.rm = TRUE)
if (sym_diff > 1e-8) stop2("Distance matrix is not symmetric. max|A - t(A)| = ", sym_diff)

diag(dist_mat) <- 0

dist_ids <- rownames(dist_mat)
if (!all(grepl("^P\\d+$", dist_ids))) {
  stop2("Row/col names must be like P1..Pn. Got: ", paste(head(dist_ids), collapse = ", "))
}

# -----------------------------
# build metadata from your rule
# P1-P10  : Young feral
# P11-P20 : Young managed
# P21-P32 : Batlow feral
# P33-P46 : Batlow managed
# -----------------------------
p_num <- as.integer(sub("^P", "", dist_ids))

region <- ifelse(p_num <= 20, "Young", "Batlow")
feral  <- ifelse(
  (p_num >= 1  & p_num <= 10) | (p_num >= 21 & p_num <= 32),
  "feral",
  "managed"
)

meta2 <- data.frame(
  sample = dist_ids,
  region = factor(region),
  feral  = factor(feral),
  stringsAsFactors = FALSE,
  row.names = dist_ids
)

cat("Metadata generated from mapping rule:\n")
print(table(meta2$region, meta2$feral))
cat("\n")

# -----------------------------
# (optional) read your provided metadata just for reference / sanity check
# not required for analysis
# -----------------------------
if (file.exists(meta_file)) {
  meta_in <- read.csv(meta_file, stringsAsFactors = FALSE)
  cat("Read external metadata with columns:\n")
  print(names(meta_in))
  cat("\n(External metadata is NOT used for modeling; mapping rule is used.)\n\n")
} else {
  cat("External metadata file not found; continuing with mapping rule only.\n\n")
}

# -----------------------------
# handle negative values
# -----------------------------
min_val <- min(dist_mat, na.rm = TRUE)
cat("Min distance value before fix:", min_val, "\n")

tol <- 1e-10
if (min_val < 0) {
  cat("Clipping negative distances to 0 (tolerance ", tol, ").\n", sep = "")
  dist_mat[dist_mat < 0] <- 0
}

dist_obj <- as.dist(dist_mat)

# -----------------------------
# run adonis2
# -----------------------------
set.seed(123)

m_full <- adonis2(dist_obj ~ region * feral, data = meta2, permutations = 999, by = "margin")
m_add  <- adonis2(dist_obj ~ region + feral, data = meta2, permutations = 999, by = "margin")

# -----------------------------
# write outputs
# -----------------------------
out_txt <- paste0(out_prefix, "_adonis2_output.txt")
out_csv_full <- paste0(out_prefix, "_adonis2_full_regionXferal.csv")
out_csv_add  <- paste0(out_prefix, "_adonis2_additive_region+feral.csv")
out_session  <- paste0(out_prefix, "_sessionInfo.txt")
out_meta     <- paste0(out_prefix, "_metadata_used.csv")

sink(out_txt)
cat("### adonis2: region * feral (by = margin)\n")
print(m_full)
cat("\n\n### adonis2: region + feral (by = margin)\n")
print(m_add)
sink()

write.csv(as.data.frame(m_full), out_csv_full, quote = FALSE)
write.csv(as.data.frame(m_add),  out_csv_add,  quote = FALSE)
write.csv(meta2, out_meta, quote = FALSE)

sink(out_session)
sessionInfo()
sink()

cat("\nDone.\nWrote:\n",
    " - ", out_txt, "\n",
    " - ", out_csv_full, "\n",
    " - ", out_csv_add, "\n",
    " - ", out_meta, "\n",
    " - ", out_session, "\n", sep = "")
