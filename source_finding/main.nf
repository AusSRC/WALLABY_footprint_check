#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// ----------------------------------------------------------------------------------------
// Processes
// ----------------------------------------------------------------------------------------

// Check dependencies for pipeline run
process pre_run_dependency_check {
    input: 
        val footprints
        val weights
        val sofia_parameter_file

    output:
        stdout emit: stdout

    script:
        """
        #!/bin/bash
        # Ensure image cube exists
        [ ! -f $footprints ] && \
            { echo "Source finding image cube not found"; exit 1; }

        # Ensure weights cube exists
        [ ! -f $weights ] && \
            { echo "Source finding weights cube not found"; exit 1; }
        exit 0
        """
}

// Create scripts for running SoFiA via SoFiAX
process s2p_setup {
    container = params.S2P_IMAGE
    containerOptions = '--bind /mnt/shared:/mnt/shared'

    input:
        val image_cube_file
        val sofia_parameter_file_template
        val check

    output:
        val "${params.WORKDIR}/${params.RUN_NAME}/${params.SOFIAX_CONFIG_FILE}", emit: sofiax_config

    script:
        """
        python3 -u /app/s2p_setup.py \
            ${params.S2P_TEMPLATE} \
            $image_cube_file \
            $sofia_parameter_file_template \
            ${params.RUN_NAME} \
            ${params.WORKDIR}/${params.RUN_NAME}
        """
}

// Fetch parameter files from the filesystem (dynamically)
process get_parameter_files {
    executor = 'local'

    input:
        val sofiax_config

    output:
        val parameter_files, emit: parameter_files

    exec:
        parameter_files = file("${params.WORKDIR}/${params.RUN_NAME}/sofia_*.par")
}

// Run source finding application (sofia)
process sofia {
    container = params.SOFIA_IMAGE
    containerOptions = '--bind /mnt/shared:/mnt/shared'
    
    input:
        file parameter_file

    output:
        path parameter_file, emit: parameter_file

    script:
        """
        #!/bin/bash
        
        OMP_NUM_THREADS=8 sofia $parameter_file
        """
}

// ----------------------------------------------------------------------------------------
// Workflow
// ----------------------------------------------------------------------------------------

workflow source_finding {
    take: 
        footprints
        weights
        sofia_parameter_file

    main:
        pre_run_dependency_check(footprints, weights, sofia_parameter_file)
        s2p_setup(footprints, sofia_parameter_file, pre_run_dependency_check.out.stdout)
        get_parameter_files(s2p_setup.out.sofiax_config)
        sofia(get_parameter_files.out.parameter_files.flatten())
}

// ----------------------------------------------------------------------------------------
