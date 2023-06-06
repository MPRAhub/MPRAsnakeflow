
snakemake --snakefile MPRAsnakeflow-master/workflow/Snakefile \
--use-conda \
--rerun-incomplete \
--configfile config-assignment.yaml \
--verbose \
-c 8 > standard.out
