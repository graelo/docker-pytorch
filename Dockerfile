FROM debian:stretch
MAINTAINER u0xy <u0xy@u0xy.cc>

RUN apt-get update -qq \
  && apt-get install -y apt-utils \
  && apt-get upgrade -y \
  #
  # python
  # && apt-get install -y python3-pip python3-tk \
  && apt-get install -y curl \
      build-essential   # gcc for xgboost \
  #
  # cleanup
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


WORKDIR /root
COPY resources/install-python-packages.sh .
COPY resources/ptpython-config.py .


# Miniconda
RUN \
  # curl -L https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh \
  curl -L https://repo.continuum.io/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh -o miniconda.sh \
  && bash miniconda.sh -b -p /usr/local/miniconda \
  && rm -f miniconda.sh \
  && echo 'export PATH="/usr/local/miniconda/bin:$PATH"' >> ~/.bashrc \
  && /bin/bash -c "\
  source ~/.bashrc \
  #
  #
  && source install-python-packages.sh \
  #
  #
  && jupyter serverextension enable --py jupyterlab --sys-prefix \
  && jupyter nbextension enable --py widgetsnbextension --sys-prefix \
  && jupyter labextension install @jupyter-widgets/jupyterlab-manager \
  #
  && conda clean --all -y \
  #
  && rm -f install-python-packages.sh \
  && mkdir ~/.ptpython && mv ptpython-config.py ~/.ptpython/config.py \
  "


EXPOSE 8888 6006

CMD ["/usr/local/miniconda/bin/jupyter", "lab", "--ip", "0.0.0.0", "--no-browser", "--allow-root", "--NotebookApp.token=''"]
