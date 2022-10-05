# --use-pseudo-counts
rule variants_generateVariantTable:
    conda:
        "../envs/python3.yaml"
    input:
        variant_definition=lambda wc: getVariants(wc.project)["map"],
        counts="results/experiments/{project}/assigned_counts/{assignment}/{config}/{condition}_{replicate}_merged_assigned_counts.tsv.gz",
        script=getScript("variants/generateVariantTable.py"),
    output:
        "results/experiments/{project}/variants/{assignment}/{config}/{condition}_{replicate}_variantTable.tsv.gz",
    log:
        temp(
            "tesults/logs/experiments/variants/generateVariantTable.{project}.{assignment}.{config}.{condition}.{replicate}.log"
        ),
    shell:
        """
        python {input.script} \
        --counts {input.counts} \
        --declaration {input.variant_definition} \
        --output {output} &> {log}
        """


rule variants_MasterTable:
    conda:
        "../envs/python3.yaml"
    input:
        variants=lambda wc: expand(
            "results/experiments/{{project}}/variants/{{assignment}}/{{config}}/{{condition}}_{replicate}_variantTable.tsv.gz",
            replicate=getReplicatesOfCondition(wc.project, wc.condition),
        ),
        script=getScript("variants/generateMasterVariantTable.py"),
    output:
        "results/experiments/{project}/variants/{assignment}/{config}/{condition}_variantTable.tsv.gz",
    params:
        input=lambda wc: " ".join(
            [
                "--input %s" % i
                for i in expand(
                    "results/experiments/{project}/variants/{assignment}/{config}/{condition}_{replicate}_variantTable.tsv.gz",
                    replicate=getReplicatesOfCondition(wc.project, wc.condition),
                    project=wc.project,
                    assignment=wc.assignment,
                    config=wc.config,
                    condition=wc.condition,
                )
            ]
        ),
        minRNACounts=lambda wc: counts_getFilterConfig(
            wc.project, wc.config, "RNA", "min_counts"
        ),
        minDNACounts=lambda wc: counts_getFilterConfig(
            wc.project, wc.config, "DNA", "min_counts"
        ),
    log:
        temp(
            "results/logs/experiments/variants/MasterTable.{project}.{assignment}/{config}.{condition}.log"
        ),
    shell:
        """
        python {input.script} \
        {params.input} \
        --minRNACounts {params.minRNACounts} \
        --minDNACounts {params.minDNACounts} \
        --output {output} &> {log}
        """


rule variants_correlate:
    conda:
        "../envs/python3.yaml"
    input:
        counts=lambda wc: expand(
            "results/experiments/{{project}}/variants/{{assignment}}/{{config}}/{{condition}}_{replicate}_variantTable.tsv.gz",
            replicate=getReplicatesOfCondition(wc.project, wc.condition),
        ),
        script=getScript("variants/correlateVariantTables.py"),
    output:
        "results/experiments/{project}/statistic/variants/{assignment}/{config}/{condition}/{condition}_correlation_variantTable_minBC{threshold}.tsv.gz",
    params:
        cond="{condition}",
        threshold="{threshold}",
        tables=lambda wc: " ".join(
            expand(
                "--variants {replicate} results/experiments/{project}/variants/{assignment}/{config}/{condition}_{replicate}_variantTable.tsv.gz",
                project=wc.project,
                assignment=wc.assignment,
                config=wc.config,
                condition=wc.condition,
                replicate=getReplicatesOfCondition(wc.project, wc.condition),
            )
        ),
    log:
        temp(
            "results/logs/experiments/variants/correlate.{project}.{assignment}.{config}.{condition}.{condition}.{threshold}.log"
        ),
    shell:
        """
        python {input.script} \
        --condition {params.cond} \
        {params.tables} \
        --bc-threshold {params.threshold} \
        --output {output} &> {log}
        """


rule variants_combineVariantCorrelationTables:
    conda:
        "../envs/default.yaml"
    input:
        correlation=lambda wc: expand(
            "results/experiments/{{project}}/statistic/variants/{{assignment}}/{{config}}/{condition}/{condition}_correlation_variantTable_minBC{threshold}.tsv.gz",
            condition=getConditions(wc.project),
            threshold=getVariantsBCThreshold(wc.project),
        ),
    output:
        report(
            "results/experiments/{project}/statistic/variants/{assignment}/{config}/correlation_variantTable.tsv",
            caption="../report/variants/correlation.rst",
            category="{project}",
            subcategory="Variants",
            labels={
                "Analysis": "Correlation",
                "Configuration": "{config}",
                "Assignment": "{assignment}",
            },
        ),
    log:
        temp(
            "results/logs/experiments/variants/combineVariantCorrelationTables.{project}.{assignment}.{config}.log"
        ),
    shell:
        """
        set +o pipefail;
        (
        zcat {input.correlation[0]} | head -n 1;
        for i in {input.correlation}; do
            zcat $i | tail -n +2;
        done;
        ) > {output} 2> {log}
        """
