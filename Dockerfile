FROM ubuntu:18.04

LABEL maintainer="u0xy <u0xy@u0xy.cc>"
LABEL description="🐳 Docker environment for Swift GPU Accelerated Machine Learning"
LABEL url="https://github.com/u0xy/docker-pytorch"

RUN apt-get update -qq \
  && apt-get install -y apt-utils \
  && apt-get upgrade -y \
  #
  # python
  # && apt-get install -y python3-pip python3-tk \
  && apt-get install -y sudo curl git \
      build-essential \
      clang libpython-dev libblocksruntime-dev \
      libpython3.6 libxml2 \
  #
  # cleanup
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV LANG=C.UTF-8 \
    SHELL=/bin/bash \
    NB_USER=mluser \
    NB_UID=1000 \
    NB_GID=100 \
    HOME=/home/mluser \
    S4TF_HOME=/home/mluser/s4tf \
    S4TF_URL=https://storage.googleapis.com/swift-tensorflow-artifacts/nightlies/latest/swift-tensorflow-DEVELOPMENT-cuda10.1-cudnn7-ubuntu18.04.tar.gz \
    TENSORBOARD_LOGDIR=/data/tensorboard_logdir
# latest stable: https://storage.googleapis.com/swift-tensorflow-artifacts/nightlies/latest/swift-tensorflow-DEVELOPMENT-cuda10.1-cudnn7-ubuntu18.04.tar.gz

ADD fix-permissions /usr/bin/fix-permissions

RUN \
  #
  # create user
  groupadd $NB_USER && useradd -d /home/$NB_USER -ms /bin/bash -g $NB_GID -G sudo,video -p $NB_USER $NB_USER \
  && chmod g+w /etc/passwd /etc/group \
  && chown -R $NB_USER:$NB_USER /usr/local \
  #
  # create data dirs
  && mkdir -p /data/tensorboard_logdir /data/input /data/output \
  && chown -R $NB_USER:$NB_USER /data

WORKDIR /home/$NB_USER

# SwiftAI
RUN \
  mkdir $S4TF_HOME && cd $S4TF_HOME \
  && curl $S4TF_URL | tar xz \
  && echo export PATH="$S4TF_HOME/usr/bin:$PATH" >> $HOME/.bashrc \
  && cd ..

COPY resources/install-python-packages.sh .
COPY resources/ptpython-config.py .


# Miniconda
RUN \
  # curl -L https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh \
  curl -L https://repo.continuum.io/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh -o miniconda.sh \
  && bash miniconda.sh -b -p /usr/local/miniconda \
  && rm -f miniconda.sh \
  && echo 'export PATH="/usr/local/miniconda/bin:$PATH"' >> $HOME/.bashrc \
  && /bin/bash -c "\
  export PATH='/usr/local/miniconda/bin:$PATH' \
  && echo 'installing for $NB_USER ($NB_GID) $HOME' \
  #
  && conda update -n base conda \
  #
  #
  && source install-python-packages.sh \
  #
  #
  && echo '** cleaning caches...' \
  && conda clean --all -y \
  && rm -rf /home/${NB_USER}/.cache/pip \
  && echo '** cleaning caches done.' \
  #
  && rm -f install-python-packages.sh \
  && mkdir ${HOME}/.ptpython && mv ${HOME}/ptpython-config.py ${HOME}/.ptpython/config.py \
  #
  && chown -R $NB_USER:$NB_USER $HOME \
  && chown -R $NB_USER:$NB_USER /usr/local/miniconda \
  "

USER $NB_USER

EXPOSE 8888

CMD ["/usr/local/miniconda/bin/jupyter", "lab", "--ip", "0.0.0.0", "--no-browser", "--allow-root", "--NotebookApp.token=''"]
