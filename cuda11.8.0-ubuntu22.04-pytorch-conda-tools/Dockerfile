# Base pytorch image
FROM ghcr.io/viwainvestgmbh/runpod-llm-cuda118-pytorch-base:latest as base

ARG APTPKGS="git-lfs tmux tldr neovim rsync net-tools less iputils-ping 7zip zip unzip"

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends $APTPKGS && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN git config --global credential.helper store && \
    git lfs install

ENV BASH="/bin/bash" \
    LOCALE="en_US.UTF-8" \
    TZ="EU/Berlin" \
    DEBIAN_FRONTEND="noninteractive"

SHELL ["/bin/bash", "-c"] 

ARG WORKER_HOME=/workspace/worker 
ARG ANACONDA_INSTALLER=Anaconda3-2023.03-1-Linux-x86_64.sh
ARG ANACONDA_HOME=/workspace/worker/anaconda3
ARG ANACONDA_BIN="${ANACONDA_HOME}/bin"

USER worker
workdir $WORKER_HOME

ENV PATH "/usr/local/cuda/bin":$PATH

RUN mkdir -p ${WORKER_HOME}/data/datasets
RUN mkdir -p ${WORKER_HOME}/data/models
RUN mkdir -p ${WORKER_HOME}/data/utils
RUN mkdir -p ${WORKER_HOME}/data/loras

COPY scripts ${WORKER_HOME}/scripts
COPY env-files/textgen.yml ${WORKER_HOME}/textgen.yml
COPY repos.txt ${WORKER_HOME}/repos.txt
COPY conf-files/vimrc $WORKER_HOME/.vimrc
COPY conf-files/tmux.conf $WORKER_HOME/.tmux.conf


RUN sudo -u root chown worker:worker ${WORKER_HOME}/textgen.yml
RUN sudo -u root chown worker:worker ${WORKER_HOME}/repos.txt
RUN sudo -u root chown -R worker:worker ${WORKER_HOME}/scripts
RUN sudo -u root chown worker:worker ${WORKER_HOME}/.vimrc
RUN sudo -u root chown worker:worker ${WORKER_HOME}/.tmux.conf

RUN conda env create -f ${WORKER_HOME}/textgen.yml && rm -f ${WORKER_HOME}/textgen.yml

ENV PATH_FOR_ROOT $PATH
ENV PATH ${ANACONDA_HOME}/envs/textgen/bin:$PATH

SHELL ["conda", "run", "-n", "textgen", "/bin/bash", "-c"]

RUN git clone https://github.com/oobabooga/text-generation-webui && \
    cd text-generation-webui && \
    pip install -r requirements.txt && \
    bash -c 'for req in extensions/*/requirements.txt ; do pip install -r "$req" ; done' && \
    mkdir -p repositories && \
    cd repositories && \
    git clone https://github.com/turboderp/exllama && \
    pip install -r exllama/requirements.txt

ARG AUTOGPTQ="0.2.2"
ENV CUDA_VERSION=""
ENV GITHUB_ACTIONS=true
ENV TORCH_CUDA_ARCH_LIST="8.0;8.6+PTX;8.9;9.0" 
RUN pip uninstall -y auto-gptq && \
    pip install --no-cache-dir auto-gptq==$AUTOGPTQ

#RUN touch ${WORKER_HOME}/do.not.launch.UI

USER root
WORKDIR /

COPY start-ui.sh /start.sh

RUN chmod +x /start.sh

CMD [ "/start.sh" ]

