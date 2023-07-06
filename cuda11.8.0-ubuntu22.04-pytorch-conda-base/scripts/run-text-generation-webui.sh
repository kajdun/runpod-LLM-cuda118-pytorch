#!/bin/bash
#cd /workspace/text-generation-webui

USER=worker
VOLUME=/workspace/$USER
SCRIPTDIR=$VOLUME/scripts

# Edit these arguments if you want to customise text-generation-webui launch.
# Don't remove "$@" from the start unless you want to prevent automatic model loading from template arguments
ARGS=("$@" --listen)

echo "Launching text-generation-webui with args: ${ARGS[@]}"

cd $VOLUME/text-generation-webui && conda run -n textgen python server.py "${ARGS[@]}" 