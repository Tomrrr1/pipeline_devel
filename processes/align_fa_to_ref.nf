process ALIGN_FA_TO_REF {
    tag "$meta.sample_id"
    label "process_single"

    input:
        tuple val(meta), path(assembly_fasta)

    output:
        tuple val(meta), path("${meta.sample_id}_sorted.bam"), emit: aligned_fa_bam
        tuple val(meta), path("*.bai"), emit: aligned_fa_bai

    script:
        """
        minimap2 -x asm5 -a ${meta.reference} ${assembly_fasta} > ${meta.sample_id}.sam
		samtools sort -o ${meta.sample_id}_sorted.bam ${meta.sample_id}.sam
		samtools index ${meta.sample_id}_sorted.bam
        """
}