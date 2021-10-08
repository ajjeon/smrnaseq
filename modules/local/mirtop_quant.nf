// Import generic module functions
include { saveFiles; initOptions; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process MIRTOP_QUANT {
    label 'process_medium'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:".", meta:[:], publish_by_meta:[]) }

    conda (params.enable_conda ? 'bioconda::mirtop=0.4.23 bioconda::samtools=1.13 conda-base::r-base=4.0.3' : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/mulled-v2-1f73c7bc18ac86871db9ef0a657fb39d6cbe1cf5:dd7c9649e165d535c1dd2c162ec900e7206398ec-0"
    } else {
        // container "nfcore/smrnaseq:dev"
        container "quay.io/biocontainers/mulled-v2-1f73c7bc18ac86871db9ef0a657fb39d6cbe1cf5:dd7c9649e165d535c1dd2c162ec900e7206398ec-0"
    }

    input:
    path ("bams/*")
    path hairpin
    path gtf

    output:
    path "mirtop/mirtop.gff"
    path "mirtop/mirtop.tsv", emit: mirtop_table
    // path "mirtop/mirna.tsv"
    path "mirtop/mirtop_rawData.tsv"
    path "*.version.txt" , emit: versions

    script:
    def software = getSoftwareName(task.process)
    """
    mirtop gff --hairpin $hairpin --gtf $gtf -o mirtop --sps $params.mirtrace_species ./bams/*
    mirtop counts --hairpin $hairpin --gtf $gtf -o mirtop --sps $params.mirtrace_species --add-extra --gff mirtop/mirtop.gff
    mirtop export --format isomir --hairpin $hairpin --gtf $gtf --sps $params.mirtrace_species -o mirtop mirtop/mirtop.gff
    #collapse_mirtop.r mirtop/mirtop.tsv
    echo \$(mirtop --version 2>&1) | sed 's/^.*mirtop //' > ${software}.version.txt
    """

}