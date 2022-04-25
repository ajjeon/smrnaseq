#!/bin/bash

# run it in the project directory where main.nf is located

nextflow run main.nf \
	 -profile docker,aws \
	 -c myconfig.config \
	 -bucket-dir s3://ahjung/PNK/smrnaseq/ \
	 --input 's3://00-sequencing-data-bgi/F22FTSAPHT0261_HUMamfrS/soapnuke/clean/*/*{1,2}.fq.gz' \
	 --outdir 's3://ahjung/PNK/smrnaseq/results/' \
	 -work-dir 's3://ahjung/PNK/smrnaseq/work/' \
	 --genome GRCh38 \
	 -resume
