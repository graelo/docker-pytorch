# Dockerized {pytorch 0.3.1 & friends} + CUDA 9.1 + cuDNN 7 (personal use)

Also includes scikit, xgboost, pytorch, jupyterlab, ...

To run it:

    docker run --rm \
        $(ls /dev/nvidia* | xargs -I{} echo '--device={}') \
        $(ls /usr/lib/x86_64-linux-gnu/{libcuda,libnvidia}* | xargs -I{} echo '-v {}:{}:ro') \
        -e CUDA_VISIBLE_DEVICES=0 \
        -v code:/code
        u0xy/pytorch

or using `nvidia-docker`

    nvidia-docker -it --rm \
        -v ${PWD}/code:/code \
        -p 8888:8888 \
        u0xy/pytorch \
            /usr/local/bin/jupyter lab --no-browser --ip 0.0.0.0 --allow-root

If you run this container on debian, installing nvidia-docker is currently painfull, so you could also define a `nvidia-docker` shell function that looks like the following:

    function nvidia-docker() {
        docker run \
            $(ls /dev/nvidia* | xargs -I{} echo '--device={}') \
            $(ls /usr/lib/x86_64-linux-gnu/{libcuda,libnvidia}* | xargs -I{} echo '-v {}:{}:ro') \
            -e CUDA_VISIBLE_DEVICES=0 \
            $@
    }
