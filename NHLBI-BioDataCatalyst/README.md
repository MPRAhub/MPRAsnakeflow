# NHLBI-BioDataCatalyst

```bash
pip install cwltool
pip install udocker
pip install sbpack

curl https://igor.sbgenomics.com/downloads/sb/install.sh -sSf | sudo  sh
sb configure

# set default
# pack vs unpack
sbpull --unpack default andrewblair/mprasnakeflow/mprasnakeflow/43 MPRAsnakeflow.cwl

bash run-experiment.sh
bash run-assignment.sh

# Run combined with cwl

# Change cwl and push
sbpack
```