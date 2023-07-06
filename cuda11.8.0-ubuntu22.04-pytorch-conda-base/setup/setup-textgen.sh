#!/bin/bash

USER=worker
VOLUME=/workspace/$USER
SCRIPTDIR=$VOLUME/scripts


conda create -y -q -n textgen python=3.10
cd $VOLUME && git clone https://github.com/oobabooga/text-generation-webui && cd text-generation-webui
conda run -n textgen pip install -r $VOLUME/text-generation-webui/requirements.txt