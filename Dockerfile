FROM gw000/debian-cuda
MAINTAINER u0xy <u0xy@u0xy.cc>

RUN apt-get update -qq \
  && apt-get upgrade -y \
  && apt-get install -y python3-pip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN /usr/bin/pip3 install http://download.pytorch.org/whl/cu80/torch-0.2.0.post1-cp35-cp35m-manylinux1_x86_64.whl \
  && /usr/bin/pip3 install torchvision \
  && /usr/bin/pip3 install matplotlib ipython \
  && /usr/bin/pip3 install plotnine plydata
