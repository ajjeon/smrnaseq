// Import generic module functions
include { saveFiles; getSoftwareName; getProcessName } from './functions'

params.options = [:]

process PARSE_FASTA_MIRNA {
    label 'process_medium'

    conda (params.enable_conda ? 'bioconda::seqkit=2.0.0' : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/seqkit:2.0.0--h9ee0642_0"
    } else {
        container "quay.io/biocontainers/seqkit:2.0.0--h9ee0642_0"
    }

    input:
    path fasta

    output:
    path '*_igenome.fa', emit: parsed_fasta
    path "versions.yml", emit: versions

    script:
    """
    # Uncompress FASTA reference files if necessary
    FASTA="$fasta"
    if [ \${FASTA: -3} == ".gz" ]; then
        gunzip -f \$FASTA
        FASTA=\${FASTA%%.gz}
    fi
    # Remove spaces from miRBase FASTA files
    # sed -i 's, ,_,g' \$FASTA
    sed '/^[^>]/s/[^AUGCaugc]/N/g' \$FASTA > \${FASTA}_parsed.fa
    # TODO perl -ane 's/[ybkmrsw]/N/ig;print;' \${FASTA}_parsed_tmp.fa > \${FASTA}_parsed.fa

    sed -i 's/\s.*//' \${FASTA}_parsed.fa
    seqkit grep -r --pattern \".*${params.mirtrace_species}-.*\" \${FASTA}_parsed.fa > \${FASTA}_sps.fa
    seqkit seq --rna2dna \${FASTA}_sps.fa > \${FASTA}_igenome.fa

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        seqkit: \$(echo \$(seqkit 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
    END_VERSIONS
    """

}
