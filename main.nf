#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
include { source_finding } from './source_finding/main'
include { moment0 } from './moment0/main'

workflow {
    sbid = "${params.SBID}"

    main:
        source_finding(sbid)
        moment0(source_finding.out.output_directory)
}