#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// ----------------------------------------------------------------------------------------
// Processes
// ----------------------------------------------------------------------------------------

// Download image cubes from CASDA
process casda_download {
    container = params.CASDA_DOWNLOAD_COMPONENTS_IMAGE
    containerOptions = "--bind ${params.SCRATCH_ROOT}:${params.SCRATCH_ROOT}"

    input:
        val sbid

    output:
        stdout emit: stdout

    script:
        """
        XDG_CACHE_HOME=${params.ASTROPY_CACHEDIR} python3 -u /app/casda_download.py \
            -i $sbid \
            -o ${params.WORKDIR}/${params.SBID} \
            -u '${params.CASDA_USERNAME}' \
            -p '${params.CASDA_PASSWORD}' \
            -q '${params.DOWNLOAD_QUERY}'
        """
}

// Find downloaded images on file system
// TODO(austin): probably don't need to download weights
process get_downloaded_files {
    executor = 'local'

    input:
        val casda_download

    output:
        val footprints, emit: footprints
        val weights, emit: weights

    exec:
        footprints = file("${params.WORKDIR}/${params.SBID}/image.restored.i.*${params.SBID}*.cube.contsub.fits")
        weights = file("${params.WORKDIR}/${params.SBID}/weights.i.*${params.SBID}*.cube.fits")
}

// ----------------------------------------------------------------------------------------
// Workflow
// ----------------------------------------------------------------------------------------

workflow download {
    take:
        sbid

    main:
        casda_download(sbid)
        get_downloaded_files(casda_download.out.stdout)
    
    emit:
        footprints = get_downloaded_files.out.footprints
        weights = get_downloaded_files.out.weights
}

// ----------------------------------------------------------------------------------------
