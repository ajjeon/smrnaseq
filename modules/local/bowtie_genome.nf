// Import generic module functions
include { saveFiles; initOptions; getSoftwareName; getProcessName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process INDEX_GENOME {
    tag "$fasta"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process)+"/${options.suffix}", meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? 'bioconda::bowtie=1.3.0-2' : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/bowtie:1.3.0--py38hcf49a77_2"
    } else {
        container "quay.io/biocontainers/bowtie:1.3.0--py38hcf49a77_2"
    }

    input:
    path fasta

    output:
    path 'genome*ebwt'     , emit: bt_indices
    path 'genome.edited.fa', emit: fasta
    path "versions.yml"    , emit: versions

    script:
    """
    # Remove any special base characters from reference genome FASTA file
    sed '/^[^>]/s/[^ATGCatgc]/N/g' $fasta > genome.edited.fa
    sed -i 's/ .*//' genome.edited.fa

    # Build bowtie index
    bowtie-build genome.edited.fa genome --threads ${task.cpus}

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        bowtie: \$(echo \$(bowtie --version 2>&1) | sed 's/^.*bowtie-align-s version //; s/ .*\$//')
    END_VERSIONS
    """

}
