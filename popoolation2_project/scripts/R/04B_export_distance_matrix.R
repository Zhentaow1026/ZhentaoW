library(poolfstat)
library(ade4)

# It has not been uploaded to GitHub！
sync_file <- "sync/all_regions1.sync"

# infer pool count
first_line <- readLines(sync_file, n = 1)
n_cols <- length(strsplit(first_line, "\t")[[1]])
n_pools <- n_cols - 3
cat("n_pools =", n_pools, "\n")

# poolsizes
n_ind <- 10
poolsizes <- rep(2 * n_ind, n_pools)

# read sync -> pooldata
pooldata <- popsync2pooldata(sync.file = sync_file, poolsizes = poolsizes)

# pairwise FST
fst_obj <- compute.pairwiseFST(pooldata)

# linearise
fst <- fst_obj@PairwiseFSTmatrix
linear_fst <- fst / (1 - fst)

# turn into dist
dist_obj <- as.dist(linear_fst)

# check euclidean and fix
is_e <- ade4::is.euclid(dist_obj)
cat("is_euclid =", is_e, "\n")

if (!is_e) {
  dist_eucl <- ade4::cailliez(dist_obj)  # returns a 'dist'
} else {
  dist_eucl <- dist_obj
}

# export
out_dir <- "results"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# dist_obj matrix csv
mat_linear <- as.matrix(dist_obj)
write.csv(mat_linear, file = file.path(out_dir, "distance_matrix_linearFST.csv"), quote = FALSE)

# dist_eucl matrix csv
mat_eucl <- as.matrix(dist_eucl)
write.csv(mat_eucl, file = file.path(out_dir, "distance_matrix_cailliez.csv"), quote = FALSE)

cat("Wrote:\n",
    file.path(out_dir, "distance_matrix_linearFST.csv"), "\n",
    file.path(out_dir, "distance_matrix_cailliez.csv"), "\n")
