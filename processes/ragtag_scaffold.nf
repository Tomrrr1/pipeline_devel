process RAGTAG_SCAFFOLD {
    tag "$meta.sample_id"
    label "process_single"
    publishDir "${params.outdir}/results/02_CONTIG_CORRECTION/ragtag_scaffold/${meta.sample_id}", mode: "copy"

    container "oras://community.wave.seqera.io/library/minimap2_ragtag:5ad34249839dbbbc" // reuse container from ragtag_correct

    input:
        tuple val(meta), path(corrected_fasta) // output from orient_contigs

    output:
        tuple val(meta), path("ragtag.scaffold.fasta"), emit: rt_scaffolds_fa
        tuple val(meta), path("ragtag.scaffold*"), emit: rt_scaffolds
        path("versions.yml"), emit: versions

    script: // TODO: add ragtag parameters to config file
        def VERSION = '2.1.0' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
        """
        ragtag.py scaffold ${meta.reference} ${corrected_fasta} -o .

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            ragtag: ${VERSION}
        END_VERSIONS
        """

}