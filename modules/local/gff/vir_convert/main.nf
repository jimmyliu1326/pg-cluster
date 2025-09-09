process VIRSORTER2_GFF_CONVERSION {
    tag "$samplesheet"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-e25d1fa2bb6cbacd47a4f8b2308bd01ba38c5dd7:75310f02364a762e6ba5206fcd11d7529534ed6e-0' :
        'biocontainers/mulled-v2-e25d1fa2bb6cbacd47a4f8b2308bd01ba38c5dd7:75310f02364a762e6ba5206fcd11d7529534ed6e-0' }"

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