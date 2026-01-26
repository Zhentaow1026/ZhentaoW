# adonis_minimal.R
# Run in PowerShell:
# Rscript .\adonis_minimal.R "C:\...\distance_matrix_cailliez.csv"

# ---- force user library path on Windows ----
user_lib <- file.path(Sys.getenv("USERPROFILE"), "Documents", "R", "win-library", "4.5")
if (dir.exists(user_lib)) {
  .libPaths(c(user_lib, .libPaths()))
}

suppressPackageStartupMessages({
  library(vegan)
})


args <- commandArgs(trailingOnly = TRUE)
dist_file <- if (length(args) >= 1) args[1] else "distance_matrix_cailliez.csv"

# 1) read distance matrix
d <- read.csv(dist_file, row.names = 1, check.names = FALSE)
d <- as.matrix(d)
mode(d) <- "numeric"
diag(d) <- 0

# 2) build metadata from your rule (P1..P46)
ids <- rownames(d)
p <- as.integer(sub("^P", "", ids))

metadata <- data.frame(
  region = factor(ifelse(p <= 20, "Young", "Batlow")),
  feral  = factor(ifelse((p <= 10) | (p >= 21 & p <= 32), "feral", "managed")),
  row.names = ids
)

# 3) fix negative values (adonis2 can't accept negatives)
d[d < 0] <- 0
dist_eucl <- as.dist(d)

# 4) adonis2
set.seed(123)
m1 <- adonis2(dist_eucl ~ region * feral, data = metadata, permutations = 999, by = "margin")
m2 <- adonis2(dist_eucl ~ region + feral,  data = metadata, permutations = 999, by = "margin")

print(m1)
cat("\n")
print(m2)
