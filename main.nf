#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
include { source_finding } from './source_finding/main'
include { moment0 } from './moment0/main'

workflow {
    footprint = "${params.FOOTPRINT}"
    sofia_parameter_file = "${params.SOFIA_PARAMETER_FILE}"

    main:
        source_finding(footprint, sofia_parameter_file)
        moment0(source_finding.out.output_directory)
}