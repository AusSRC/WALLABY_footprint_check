<h1 align="center"><a href="https://aussrc.github.io/WALLABY_workflows/">WALLABY footprint check</a></h1>

WALLABY survey nextflow workflow for executing a quality check pipeline on ASKAP image cube footprints. Developed by the [AusSRC](https://aussrc.org). 

# Overview

This pipeline is the first step of data processing that is run on ASKAP data in the archive. Makes the assumption that the image files of interest are available on the system where this pipeline is executed. This code will do the following:

1. Run the source finding application on a WALLABY footprint
2. Run `wallmerge.py` (see [code here](https://github.com/AusSRC/pipeline_components/tree/main/pre_check)) to generate a moment 0 map of cube

Once the moment 0 map is generated, a WALLABY project scientist will inspect the product and determine whether the footprint is of sufficient quality for post-processing.

# Run pipeline

To execute the pipeline with parameter file `params.yaml` use the command below. In running the pipeline you will need to specify the `profile`, which determines the default configuration to use. The options can be found in [`nextflow.config`](nextflow.config)

```
nextflow run https://github.com/AusSRC/WALLABY_footprint_check -r main -params-file params.yaml -profile carnaby
```

You can read about the different `nextflow` configuration options [here](https://www.nextflow.io/docs/latest/config.html#).

# Parameters

Each pipeline will be run with different parameters which are used to determine the footprint that is processed and the location of the output products that are created. Many parameters have default values which can be found in the [`nextflow.config`](nextflow.config). 

The required parameters for each run of the pipeline are the footprint file location and the name of the run. 

```
{
  "FOOTPRINT": "image.restored.i.NGC4808_B.SB37604.cube.contsub.fits",
  "RUN_NAME": "NGC5044_2"
}
```

There are additional optional configuration items that users may choose to change for any given run which include

* `WORKDIR` - parent directory for all runs of this pipeline
* `SOFIA_PARAMETER_FILE` - `sofia` parameter file template
* `S2P_TEMPLATE` - `s2p_setup` configuration file template
* `OUTPUT_DIR` - output directory of source finding and `wallmerge` products

We don't recommend you change the default values for other parameters in the [`nextflow.config`](nextflow.config) as they relate to the execution environment.
