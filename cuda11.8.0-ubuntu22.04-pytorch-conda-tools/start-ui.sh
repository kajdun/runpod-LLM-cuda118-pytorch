#!/bin/bash
echo "Pod started"

USER=worker
VOLUME=/workspace/$USER
SCRIPTDIR=$VOLUME/scripts

# If a volume is already defined, $VOLUME will already exist
# If a volume is not being used, we'll still use /worksapce to ensure everything is in a known place.
su -c "mkdir -p $VOLUME/logs" -m "$USER" 

# Start build of llama-cpp-python in background
#if [[ ! -f /.built.llama-cpp-python ]]; then
#	su -c "$SCRIPTDIR/build-llama-cpp-python.sh >>$VOLUME/logs/build-llama-cpp-python.log 2>&1 &" -m "$USER"
#fi

if [[ $PUBLIC_KEY ]]; then
	mkdir -p ~/.ssh
	chmod 700 ~/.ssh
	cd ~/.ssh
	echo "$PUBLIC_KEY" >>authorized_keys
	chmod 700 -R ~/.ssh
	service ssh start
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

		($SCRIPTDIR/run-text-generation-webui.sh "${ARGS[@]}" 2>&1) >>$VOLUME/logs/text-generation-webui.log

	fi
	sleep 2
done

# shouldn't actually reach this point
sleep infinity