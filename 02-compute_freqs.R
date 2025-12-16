### Compute allele frequencies for 4 populations

# Load files
YF <- read.csv("YoungFeral_counts.csv")
YM <- read.csv("YoungManaged_counts.csv")
BF <- read.csv("BatlowFeral_counts.csv")
BM <- read.csv("BatlowManaged_counts.csv")

# Function to compute allele frequency
compute_freq <- function(df) {
  df$af <- ifelse(df$depth > 0, df$alt / df$depth, NA)
  return(df)
}

YF <- compute_freq(YF)
YM <- compute_freq(YM)
BF <- compute_freq(BF)
BM <- compute_freq(BM)

# Save outputs
write.csv(YF, "YoungFeral_freq.csv", row.names = FALSE)
write.csv(YM, "YoungManaged_freq.csv", row.names = FALSE)
write.csv(BF, "BatlowFeral_freq.csv", row.names = FALSE)
write.csv(BM, "BatlowManaged_freq.csv", row.names = FALSE)

cat("Done. Output files:\n")
cat("YoungFeral_freq.csv\n")
cat("YoungManaged_freq.csv\n")
cat("BatlowFeral_freq.csv\n")
cat("BatlowManaged_freq.csv\n")
