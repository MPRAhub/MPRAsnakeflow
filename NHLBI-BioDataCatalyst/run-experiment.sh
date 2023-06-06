
snakemake --snakefile MPRAsnakeflow-master/workflow/Snakefile \
--use-conda \
--configfile config-experiment.yaml \
--verbose \
-c 8 > standard.out
