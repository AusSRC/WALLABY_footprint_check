#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// ----------------------------------------------------------------------------------------
// Processes
// ----------------------------------------------------------------------------------------

// Check dependencies for pipeline run
process pre_run_dependency_check {
    input: 
        val output_directory

    output:
        stdout emit: stdout

    script:
        """
        #!/bin/bash
        # Ensure output directory exists
        [ ! -f $footprints ] && \
            { echo "Source finding image cube not found"; exit 1; }

        exit 0
        """
}

// Create scripts for running SoFiA via SoFiAX
process mosaick {
    container = params.WALLMERGE_IMAGE
    containerOptions = '--bind /mnt/shared:/mnt/shared'

    input:
        val output_directory
        val check

    output:
        stdout emit: stdout

    script:
        """
        python3 -u /app/run_wallmerge.py \
            $output_directory
        """
}

// ----------------------------------------------------------------------------------------
// Workflow
// ----------------------------------------------------------------------------------------

workflow moment0 {
    take:
        output_directory
        source_finding

    main:
        pre_run_dependency_check(output_directory)
        mosaick(output_directory, pre_run_dependency_check.out.stdout)
}

// ----------------------------------------------------------------------------------------
