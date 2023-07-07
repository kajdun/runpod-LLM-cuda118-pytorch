#!/bin/bash

echo "pod started"

USER=worker
VOLUME=/workspace/$USER
SCRIPTDIR=$VOLUME/scripts

if [[ $PUBLIC_KEY ]]; then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo "$PUBLIC_KEY" >>authorized_keys
    chmod 700 -R ~/.ssh
    service ssh start
    echo "ssh started"
fi

    if [[ $JUPYTER_PASSWORD ]]
    then
        cd /
        jupyter lab --allow-root --no-browser --port=8888 --ip=* --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' --ServerApp.token='' --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace &
        echo "jupyter started"
    fi  


if [ ! -f "/workspace/worker/anaconda3" ]; then
    echo "Installing Anaconda"
    su -l -c "/bin/bash /workspace/worker/setup/setup-anaconda.sh" -m "$USER"
else
    echo "Conda already installed."
fi

# If a volume is already defined, $VOLUME will already exist
# If a volume is not being used, we'll still use /worksapce to ensure everything is in a known place.
su -c "mkdir -p $VOLUME/logs" -m "$USER" 

if [ ! -f "/workspace/worker/anaconda3/envs/textgen/bin/python" ]; then
    echo "Installing text-generation-webui"
    su -l -c "/bin/bash /workspace/worker/setup/setup-textgen.sh" -m "$USER"
else
    echo "Conda environment textgen for text-generation-webui already present. Skipping installation."
fi

ARGS=()
while true; do
    # If the user wants to stop the UI from auto launching, they can run:
    # touch $VOLUME/do.not.launch.UI
    if [[ ! -f $VOLUME/do.not.launch.UI ]]; then
        # Launch the UI in a loop forever, allowing UI restart
        if [[ ${UI_ARGS} ]]; then
            # Passed arguments in the template
            ARGS=("${ARGS[@]}" ${UI_ARGS})
        fi

        (su -l -c "/bin/bash $SCRIPTDIR/run-text-generation-webui.sh ${ARGS[@]}" -m "$USER" 2>&1) >>$VOLUME/logs/text-generation-webui.log

    fi

    sleep 2
done

# shouldn't actually reach this point
sleep infinity