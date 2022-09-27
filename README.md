# WALLABY footprint check

WALLABY workflow for executing a quality check pipeline on ASKAP image cube footprints. Developed by the [AusSRC](https://aussrc.org).

# Overview

Does the following

1. Download from CASDA (optional)
2. Run source finding pipeline on footprint
3. Generate moment 0 map of detections

Scientists can then inspect the moment 0 map to determine whether the footprint is good quality or not to report back to CASDA for release to level 6.

# Configuration

To configure the pipeline specify a `params.yaml` file with the following content

- For the `main.nf` pipeline which will download image and weights cubes from a provided SBID:

```
{
  "RUN_NAME": "Test"
  "SBID": "34302",
}
```

- Or for the `from_file.nf` pipeline you will need to specify the location of these files:

```
{
  "RUN_NAME": "Vela_B.SB33596",
  "IMAGE_CUBE": "/mnt/shared/wallaby/data/image.restored.i.Vela_B.SB33596.cube.contsub.fits",
  "WEIGHTS_CUBE": "/mnt/shared/wallaby/data/weights.i.Vela_B.SB33596.cube.fits",
}
```

Some default values have been provided in the [`nextflow.config`](nextflow.config). You can update them by specifying these in the parameter file.

* `WORKDIR` - parent directory for all runs of this pipeline
* `SOFIA_PARAMETER_FILE` - `sofia` parameter file template
* `S2P_TEMPLATE` - `s2p_setup` configuration file template
* `OUTPUT_DIR` - output directory of source finding and `wallmerge` products
* `WALLMERGE_OUTPUT` - output filename for mosaicked moment 0 map


# Execute

There are two options and their corresponding main scripts:

1. With download (`main.nf`)
2. With image and weights cubes downloaded locally (`from_file.nf`)

To run, use the command below and substitute `<PIPELINE>` with the main script that you wish to execute

```
nextflow run https://github.com/AusSRC/WALLABY_footprint_check -r main -main-script <PIPELINE> -params-file params.yaml -profile carnaby
```