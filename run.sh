#!/bin/bash

# run it in the project directory where main.nf is located

nextflow run main.nf \
	 -profile docker,aws \
	 -c myconfig.config \
	 -bucket-dir s3://ahjung/wgbs-test \
	 --input 's3://directory/to/inputdata/prefix_R{1,2}.fq.gz' \
	 --genome GRCh38 \
	 -resume
