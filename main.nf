#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
include { download } from './download/main'
include { source_finding } from './source_finding/main'
include { moment0 } from './moment0/main'

workflow {
    sbid = "${params.SBID}"
    sofia_parameter_file = "${params.SOFIA_PARAMETER_FILE}"

    main:
        download(sbid)
        source_finding(download.out.footprints, sofia_parameter_file)
        moment0(source_finding.out.output_directory)
}