import numpy as np
import matplotlib.pyplot as plt
import os

# assume run from repo root (popoolation2_project)
outdir = "results/coverage"
prefix = "young_F_vs_M_2pop1"
tsv = os.path.join(outdir, f"{prefix}.coverage.tsv")

cov = np.loadtxt(tsv)
c1 = cov[:, 0]
c2 = cov[:, 1]

plt.figure()
plt.hist(c1, bins=200)
plt.yscale("log")
plt.xlabel("Coverage")
plt.ylabel("Number of sites")
plt.title("Coverage distribution - pop1 (young)")
plt.savefig(os.path.join(outdir, f"{prefix}.pop1.coverage.hist.png"), dpi=200)

plt.figure()
plt.hist(c2, bins=200)
plt.yscale("log")
plt.xlabel("Coverage")
plt.ylabel("Number of sites")
plt.title("Coverage distribution - pop2 (young)")
plt.savefig(os.path.join(outdir, f"{prefix}.pop2.coverage.hist.png"), dpi=200)

print("Saved:")
print(os.path.join(outdir, f"{prefix}.pop1.coverage.hist.png"))
print(os.path.join(outdir, f"{prefix}.pop2.coverage.hist.png"))
