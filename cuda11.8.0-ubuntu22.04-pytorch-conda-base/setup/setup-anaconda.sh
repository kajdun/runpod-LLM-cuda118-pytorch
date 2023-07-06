#!/bin/bash

USER=worker
VOLUME=/workspace/$USER
SCRIPTDIR=$VOLUME/scripts


ANACONDA_INSTALLER=Anaconda3-2023.03-1-Linux-x86_64.sh
ANACONDA_HOME=/workspace/worker/anaconda3
ANACONDA_BIN="$ANACONDA_HOME/bin"

cd $VOLUME && curl -L -O "https://repo.anaconda.com/archive/${ANACONDA_INSTALLER}" \
    && chmod +x $ANACONDA_INSTALLER && ./${ANACONDA_INSTALLER} -b -p $ANACONDA_HOME \
    && rm -f $ANACONDA_INSTALLER

sudo -u root ln -s ${ANACONDA_HOME}/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    sudo -u root chmod +x ${ANACONDA_HOME}/etc/profile.d/conda.sh && \
    sudo -u root chown worker:worker ${ANACONDA_HOME}/etc/profile.d/conda.sh 


echo ". ${ANACONDA_HOME}/etc/profile.d/conda.sh" >> $VOLUME/.bashrc

#ENV PATH $ANACONDA_BIN:$PATH

$ANACONDA_BIN/conda init bash