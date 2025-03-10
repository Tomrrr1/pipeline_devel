process SUBSAMPLE_FASTQ_READS {
    tag "$meta.sample_id"
    label "process_single"
    publishDir "${params.outdir}/results/01_FASTQ_QC_REPORTS/coverage/subsampled_fastq", mode: "copy"

    input:
        tuple val(meta), path(fastq)
        val(reference_length)

    output:
        tuple val(meta), path("${meta.sample_id}*.fastq.gz"), emit: sub_fastq
    
    script:
        def target_depth = "${params.target_depth}"
        """
        # Calculate total bases in fastq
        TARGET_BASES =\$(( ${reference_length} * ${target_depth} ))
    
        # Pass through fastq file and stop when we exceed the target coverage
        zcat ${fastq} | awk -v target=\$TARGET_BASES '
            BEGIN { 
                total = 0
                rec = ""
            }
            {
                rec = rec \$0 "\\n"
                if (NR % 4 == 2) { # seq is the 2nd entry of each record
                    current_length = length(\$0)
                }
                if (NR % 4 == 0) {
                    total += current_length
                    printf "%s", rec # print record to stdout
                    rec = ""
                    if(total >= target) { exit }
                }
            }
        ' | gzip > ${meta.sample_id}_targetdepth=${target_depth}_subsampled.fastq.gz
        """
}