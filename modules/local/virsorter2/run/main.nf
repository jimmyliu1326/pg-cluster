process VIRSORTER2_RUN {
    tag "${meta.id}"
    label 'process_medium'
    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'docker://jiarong/virsorter:2.2.3'
        : 'jiarong/virsorter:2.2.3'}"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*/final-viral-boundary.tsv"), emit: boundary
    tuple val(meta), path("*/final-viral-combined.fa"), emit: fasta
    tuple val(meta), path("*/final-viral-score.tsv"), emit: score
    tuple val(meta), path("*/log"), emit: log
    tuple val(meta), path("*/config.yaml"), emit: config
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: meta.id
    """
    virsorter run \
        -j ${task.cpus} \
        -w $prefix \
        -i ${fasta} \
        ${args}

    cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            virsorter --version | tail -n1 | sed 's/.*version //g')
    END_VERSIONS
    """
}