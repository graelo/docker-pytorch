FROM gw000/debian-cuda
MAINTAINER u0xy <u0xy@u0xy.cc>

RUN apt-get update -qq \
  && apt-get upgrade -y \
  && apt-get install -y python3-pip python3-tk \
  && apt-get install -y build-essential   # gcc for xgboost \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN /usr/bin/pip3 install http://download.pytorch.org/whl/cu80/torch-0.3.0.post4-cp35-cp35m-linux_x86_64.whl \
  && /usr/bin/pip3 install \
      torchvision \
      scikit-learn xgboost \
      nltk \
      hyperopt tpot \
      matplotlib seaborn\
      plotnine plydata \
      notebook yapf \
      jupyterlab \
      tqdm \
  && /usr/local/bin/jupyter serverextension enable --py jupyterlab --sys-prefix \
  && /usr/bin/python3 -c "import nltk; nltk.download('stopwords')"

EXPOSE 8888

CMD ["/usr/local/bin/jupyter", "lab", "--ip", "0.0.0.0", "--no-browser", "--allow-root"]
