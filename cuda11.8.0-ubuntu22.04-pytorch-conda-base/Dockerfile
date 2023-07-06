FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04 as base

ENV BASH="/bin/bash" \
    LOCALE="en_US.UTF-8" \
    TZ="EU/Berlin" \
    DEBIAN_FRONTEND="noninteractive"

SHELL ["/bin/bash", "-c"]

ARG APTPKGS="wget bash python3.10-dev python3.10 openssh-server sudo tmux nvtop htop bmon screen vim neovim curl rsync net-tools git git-lfs zip unzip"

RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt install --yes --no-install-recommends $APTPKGS && \
    ln -s /usr/bin/python3.10 /usr/bin/python && \
    ln -s /usr/bin/python3.10 /usr/bin/python3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python get-pip.py

RUN pip install --no-cache-dir --pre torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/nightly/cu118
RUN pip install --no-cache-dir -U jupyterlab ipywidgets jupyter-archive jupyter_contrib_nbextensions
RUN jupyter nbextension enable --py widgetsnbextension
RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

RUN mkdir /workspace
WORKDIR /workspace

RUN useradd -b /workspace -m -s /bin/bash worker
RUN echo "worker   ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/worker

ARG WORKER_HOME=/workspace/worker 

USER worker
WORKDIR $WORKER_HOME

ENV PATH "/usr/local/cuda/bin":$PATH

RUN mkdir -p ${WORKER_HOME}/data/datasets && \
    mkdir -p ${WORKER_HOME}/data/models && \
    mkdir -p ${WORKER_HOME}/data/utils && \
    mkdir -p ${WORKER_HOME}/data/loras

COPY scripts ${WORKER_HOME}/scripts
COPY setup ${WORKER_HOME}/setup
COPY repos.txt ${WORKER_HOME}/repos.txt
COPY conf-files/vimrc $WORKER_HOME/.vimrc
COPY conf-files/tmux.conf $WORKER_HOME/.tmux.conf


RUN sudo -u root chown worker:worker ${WORKER_HOME}/repos.txt && \
    sudo -u root chown -R worker:worker ${WORKER_HOME}/scripts && \
    sudo -u root chmod +x ${WORKER_HOME}/scripts/*.sh && \
    sudo -u root chown -R worker:worker ${WORKER_HOME}/setup && \
    sudo -u root chmod +x ${WORKER_HOME}/setup/*.sh && \
    sudo -u root chown worker:worker ${WORKER_HOME}/.vimrc && \
    sudo -u root chown worker:worker ${WORKER_HOME}/.tmux.conf

USER root
WORKDIR /
SHELL ["/bin/bash", "-c"]

COPY setup.sh /start.sh

RUN chmod +x /start.sh

CMD [ "/start.sh" ]