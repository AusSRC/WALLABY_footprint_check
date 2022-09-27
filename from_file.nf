#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
include { source_finding } from './modules/source_finding'
include { moment0 } from './modules/moment0'

workflow {
    image_cube = "${params.IMAGE_CUBE}"
    weights_cube = "${params.WEIGHTS_CUBE}"

    main:
        source_finding(image_cube, weights_cube)
        moment0(source_finding.out.output_directory)
}