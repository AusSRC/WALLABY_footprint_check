#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// ----------------------------------------------------------------------------------------
// Processes
// ----------------------------------------------------------------------------------------

// Check dependencies for pipeline run
process pre_run_dependency_check {
    input: 
        file footprint
        val sofia_parameter_file

    output:
        stdout emit: stdout

    script:
        """
        #!/bin/bash
        # Ensure image cube exists
        [ ! -f $footprint ] && \
            { echo "Source finding footprint not found"; exit 1; }
        # Ensure sofia output directory exists
        [ ! -d ${params.WORKDIR}/${params.SBID}/output ] && mkdir ${params.WORKDIR}/${params.SBID}/output
        # Ensure parameter file exists
        [ ! -f ${params.SOFIA_PARAMETER_FILE} ] && \
            { echo "Source finding parameter file (params.SOFIA_PARAMETER_FILE) not found"; exit 1; }
        # Ensure s2p setup file exists
        [ ! -f ${params.S2P_TEMPLATE} ] && \
            { echo "Source finding s2p_setup template file (params.S2P_TEMPLATE) not found"; exit 1; }
        exit 0
        """
}

// Create scripts for running SoFiA via SoFiAX
process s2p_setup {
    container = params.S2P_IMAGE
    containerOptions = "--bind ${params.SCRATCH_ROOT}:${params.SCRATCH_ROOT}"

    input:
        file image_cube_file
        val sofia_parameter_file_template
        val check

    output:
        stdout emit: stdout

    script:
        """
        python3 -u /app/s2p_setup.py \
            ${params.S2P_TEMPLATE} \
            ${params.WORKDIR}/${params.SBID}/$image_cube_file \
            $sofia_parameter_file_template \
            ${params.SBID} \
            ${params.WORKDIR}/${params.SBID} \
            ${params.WORKDIR}/${params.SBID}/output
        """
}

// Fetch parameter files from the filesystem (dynamically)
process get_parameter_files {
    executor = 'local'

    input:
        val s2p_setup

    output:
        val parameter_files, emit: parameter_files

    exec:
        parameter_files = file("${params.WORKDIR}/${params.SBID}/sofia_*.par")
}

// Run source finding application (sofia)
process sofia {
    container = params.SOFIA_IMAGE
    containerOptions = "--bind ${params.SCRATCH_ROOT}:${params.SCRATCH_ROOT}"
    
    input:
        file parameter_file

    output:
        stdout emit: stdout

    script:
        """
        #!/bin/bash
        
        OMP_NUM_THREADS=8 sofia $parameter_file
        """
}

// Get output directory for moment 0 mosaicks
process get_output_directory {
    executor = 'local'

    input:
        val sofia

    output:
        val output_directory, emit: output_directory

    exec:
        output_directory = "${params.WORKDIR}/${params.SBID}/output"
}

// ----------------------------------------------------------------------------------------
// Workflow
// ----------------------------------------------------------------------------------------

workflow source_finding {
    take: 
        footprint
        sofia_parameter_file

    main:
        pre_run_dependency_check(footprint, sofia_parameter_file)
        s2p_setup(footprint, sofia_parameter_file, pre_run_dependency_check.out.stdout)
        get_parameter_files(s2p_setup.out.stdout)
        sofia(get_parameter_files.out.parameter_files.flatten())
        get_output_directory(sofia.out.stdout.collect())
    
    emit:
        output_directory = get_output_directory.out.output_directory
}

// ----------------------------------------------------------------------------------------
