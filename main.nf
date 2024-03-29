#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
include { download } from './modules/download'
include { source_finding } from './modules/source_finding'
include { moment0 } from './modules/moment0'

workflow {
    sbid = "${params.SBID}"

    main:
        download(sbid)
        source_finding(download.out.image_cube, download.out.weights_cube)
        moment0(source_finding.out.output_directory)
}