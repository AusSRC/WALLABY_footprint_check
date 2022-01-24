<h1 align="center"><a href="https://aussrc.github.io/WALLABY_workflows/">WALLABY footprint check</a></h1>

WALLABY survey pre-processing pipeline for quality check by the [AusSRC](https://aussrc.org). 

## Overview

This pipeline checks the quality of WALLABY image cube footprints in the archive, and is executed prior to the post-processing pipeline.

## Parameter file

In order to run the pipeline you will need to provide a parameter file that configures the download and source finding applications. An example has been provided below.

```
{
  # Require
  "SBIDS": "34166",
  "RUN_NAME": "NGC5044_2",
  "WORKDIR": "/mnt/shared/home/ashen/runs",
  
  # Download credentials
  "CASDA_USERNAME": "austin.shen@csiro.au",
  "CASDA_PASSWORD": "Y*Q2wQb_C4w9s-b37D",

  # Source finding parameters
  "SOFIA_PARAMETER_FILE": "/mnt/shared/home/ashen/runs/sofia.par",
  "S2P_TEMPLATE": "/mnt/shared/home/ashen/runs/s2p_setup.ini"
}
```

## Run

To execute the pipeline with parameter file `params.yaml` use the command below

```
nextflow run https://github.com/AusSRC/WALLABY_footprint_check -r main -params-file params.yaml
```
