library(poolfstat)

# # please check the root

sync_file <- "sync/batlow_exclF1_F12_keepM1_M12.sync"
out_dir <- "results/batlow_global_FST"

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

poolsizes <- rep(20, 26)
labels <- c(rep("feral",12), rep("managed",14))

# sync----pooldata
pd <- popsync2pooldata(
  sync.file = sync_file,
  poolsizes = poolsizes,
  min.rc = 4,
  min.cov.per.pool = 10,
  max.cov.per.pool = 942,
  min.maf = 0.05,
  noindel = TRUE,
  nthreads = 2
)

# aggregate 26 pools into 2 groups
make_2pool <- function(pd, labs){

  Fidx <- which(labs=="feral")
  Midx <- which(labs=="managed")

  ref <- pd@refallele.readcount
  cov <- pd@readcoverage

  new("pooldata",
      npools=2,
      nsnp=pd@nsnp,
      refallele.readcount=cbind(rowSums(ref[,Fidx]), rowSums(ref[,Midx])),
      readcoverage=cbind(rowSums(cov[,Fidx]), rowSums(cov[,Midx])),
      snp.info=pd@snp.info,
      poolsizes=c(sum(pd@poolsizes[Fidx]), sum(pd@poolsizes[Midx])),
      poolnames=c("feral","managed")
  )
}

# observed FST
pd_obs2 <- make_2pool(pd, labels)
fst_obs2 <- computeFST(pd_obs2, method="Anova", verbose=FALSE)
obs_fst <- fst_obs2$Fst[1]

# permutation
set.seed(1)
nperm <- 1000
null_fst <- numeric(nperm)

for(i in 1:nperm){
  perm_labels <- sample(labels)
  pd_perm2 <- make_2pool(pd, perm_labels)
  null_fst[i] <- computeFST(pd_perm2, method="Anova", verbose=FALSE)$Fst[1]
}

pval <- (sum(null_fst >= obs_fst) + 1) / (nperm + 1)

# save results
write.table(null_fst,
            file = file.path(out_dir, "null_fst.txt"),
            row.names = FALSE,
            col.names = FALSE,
            quote = FALSE)

cat("Observed global FST =", obs_fst, "\n")
cat("Permutation p-value =", pval, "\n")
cat("Null distribution saved to:", out_dir, "/null_fst.txt\n")
