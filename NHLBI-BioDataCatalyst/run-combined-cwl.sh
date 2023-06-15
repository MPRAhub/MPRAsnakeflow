cwltool --udocker --verbose --leave-tmpdir --cachedir ~/temp-outs MPRAsnakeflow.cwl \
--reference /sbgenomics/project-files/input_files/pilot_hepg2_elements.fa \
--zip_file /sbgenomics/workspace/MPRAsnakeflow.zip \
--data_folder /sbgenomics/project-files/input_files \
--FW_fastq /sbgenomics/project-files/input_files/pilotHepG2_R1_001.fastq.gz \
--REV_fastq /sbgenomics/project-files/input_files/pilotHepG2_R2_001.fastq.gz \
--BC_fastq /sbgenomics/project-files/input_files/pilotHepG2_I1_001.fastq.gz \
--experiment_file /sbgenomics/project-files/input_files/pilot_hepg2_experiment.csv  \
--barcode_length 15 \
--assignment_file /sbgenomics/workspace/results/assignment/exampleAssignment/assignment_barcodes.exampleConfig.sorted.tsv.gz \
--cores 32 \
--cores_1 32 \
--umi_length 10
