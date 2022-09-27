#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// ----------------------------------------------------------------------------------------
// Processes
// ----------------------------------------------------------------------------------------

// Check dependencies for pipeline run
process pre_run_dependency_check {
    output:
        stdout emit: stdout

    script:
        """
        #!/bin/bash
        # Ensure working directory exists
        [ ! -d ${params.WORKDIR}/${params.RUN_NAME} ] && mkdir ${params.WORKDIR}/${params.RUN_NAME}
        # Ensure sofia sub-cube output directory exists
        [ ! -d ${params.WORKDIR}/${params.RUN_NAME}/${params.SOFIA_OUTPUTS_DIRNAME} ] && mkdir ${params.WORKDIR}/${params.RUN_NAME}/${params.SOFIA_OUTPUTS_DIRNAME}
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
    container = params.S2P_SETUP_IMAGE
    containerOptions = "--bind ${params.SCRATCH_ROOT}:${params.SCRATCH_ROOT}"

    input:
        val image_cube_file
        val weights_cube_file
        val check

    output:
        stdout emit: stdout

    script:
        """
        python3 -u /app/s2p_setup.py \
            --config ${params.S2P_TEMPLATE} \
            --image_cube $image_cube_file \
            --run_name ${params.RUN_NAME} \
            --sofia_template ${params.SOFIA_PARAMETER_FILE} \
            --output_dir ${params.WORKDIR}/${params.RUN_NAME} \
            --products_dir ${params.WORKDIR}/${params.RUN_NAME}/${params.SOFIA_OUTPUTS_DIRNAME}
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
        parameter_files = file("${params.WORKDIR}/${params.RUN_NAME}/sofia_*.par")
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
        output_directory = "${params.WORKDIR}/${params.RUN_NAME}/${params.SOFIA_OUTPUTS_DIRNAME}"
}

// ----------------------------------------------------------------------------------------
// Workflow
// ----------------------------------------------------------------------------------------

workflow source_finding {
    take:
        image_cube
        weights_cube

    main:
        pre_run_dependency_check()
        s2p_setup(image_cube, weights_cube, pre_run_dependency_check.out.stdout)
        get_parameter_files(s2p_setup.out.stdout)
        sofia(get_parameter_files.out.parameter_files.flatten())
        get_output_directory(sofia.out.stdout.collect())

    emit:
        output_directory = get_output_directory.out.output_directory
}

// ----------------------------------------------------------------------------------------