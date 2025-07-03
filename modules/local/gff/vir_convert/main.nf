process VIRSORTER2_GFF_CONVERSION {
    tag "$samplesheet"
    label 'process_single'

    container 'oras://community.wave.seqera.io/library/pip_bio_pandas:0fe569cb5ffacb61'

    input:
    tuple val(meta), path(tool_output)
    

    output:
    tuple val(meta), path('*.gff')       , emit: gff


    when:
    task.ext.when == null || task.ext.when

    script: // This script is bundled with the pipeline, in bin/ folder
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    gff.py \\
        --input $tool_output \\
        --mode "virsorter2" \\
        --output $prefix

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}