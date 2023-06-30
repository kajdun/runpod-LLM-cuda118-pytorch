FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

RUN apt-get update --yes && \
    # - apt-get upgrade is run to patch known vulnerabilities in apt-get packages as
    #   the ubuntu base image is rebuilt too seldom sometimes (less than once a month)
    apt-get upgrade --yes && \
    apt install --yes --no-install-recommends\
    git\
    wget\
    curl\
    bash\
    software-properties-common\
    openssh-server\
    vim\
    bmon\
    screen\
    sudo
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt install python3.10 -y --no-install-recommends && \
    ln -s /usr/bin/python3.10 /usr/bin/python && \
    rm /usr/bin/python3 && \
    ln -s /usr/bin/python3.10 /usr/bin/python3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN apt-get update --yes && \
    apt install --yes --no-install-recommends\
    python3.10-venv\
    python3.10-dev\
    htop\
    nvtop\
    unzip  

RUN mkdir /workspace
WORKDIR /workspace

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python get-pip.py

RUN useradd -b /workspace -m -s /bin/bash worker
RUN echo "worker   ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/worker

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

RUN curl -L -O "https://repo.anaconda.com/archive/${ANACONDA_INSTALLER}" \
    && chmod +x $ANACONDA_INSTALLER && ./${ANACONDA_INSTALLER} -b -p $ANACONDA_HOME

RUN sudo -u root ln -s ${ANACONDA_HOME}/etc/profile.d/conda.sh /etc/profile.d/conda.sh
RUN sudo -u root chmod +x ${ANACONDA_HOME}/etc/profile.d/conda.sh
RUN sudo -u root chown worker:worker ${ANACONDA_HOME}/etc/profile.d/conda.sh 

RUN echo ". ${ANACONDA_HOME}/etc/profile.d/conda.sh" >> $WORKER_HOME/.bashrc
RUN find $ANACONDA_HOME/ -follow -type f -name '*.a' -delete && \
    find $ANACONDA_HOME/ -follow -type f -name '*.js.map' -delete && \
    ${ANACONDA_BIN}/conda clean -afy

ENV PATH $ANACONDA_BIN:$PATH

RUN conda init bash

USER root
WORKDIR /

COPY start-ssh-only.sh /start.sh

RUN chmod +x /start.sh

CMD [ "/start.sh" ]