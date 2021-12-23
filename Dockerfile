#FROM guignol95/ai-training-one-for-all
FROM python:3.9.9-slim-buster
#FROM python:3.8.12-slim-buster

RUN apt-get update && \
    apt-get install -y \
        curl \
        libmagickwand-dev \
        imagemagick \
        git \
        texlive-latex-base

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update 

RUN apt-get install --no-install-recommends -y \
    && apt-get clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

# Install jupyter-matlab-proxy dependencies
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install --yes \
        xvfb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


RUN rm /bin/sh && ln -s /bin/bash /bin/sh

WORKDIR /root
ENV HOME=/root
RUN mkdir -p /workspace



# The only folder where the user will be able to write on the host disk rather than Ceph
RUN mkdir /data && chown 42420:42420 /data

WORKDIR /workspace

# Change the default directory where pip download its dependencies
ENV PYTHONPATH /workspace/.pip/target
#ENV PATH $PATH:$PYTHONPATH/bin
#COPY pip.conf /etc/pip.conf

RUN pip install --upgrade pip

RUN pip install jupyter

RUN pip install Wand
RUN python3 -m pip install projectq
RUN pip install myqlm==1.4.0

RUN python3 -m qat.magics.install
RUN pip install myqlm-interop[all]


COPY install_tools.sh /tmp/install_tools.sh

RUN /tmp/install_tools.sh && rm /tmp/install_tools.sh

# install nvm
# https://github.com/creationix/nvm#install-script
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

ENV NVM_DIR /root/.nvm
ENV NODE_VERSION v12.20.1

# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/bin
ENV PATH $NODE_PATH:$PATH

# Install Jupyter
RUN pip install pip==20.3.4 && \
    pip install jupyterlab==2.2.9 ipywidgets==7.6.3 && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter nbextension enable --py widgetsnbextension #enable ipywidgets

# Install integration
RUN python3 -m pip install jupyterlab

# Ensure jupyter-server-proxy JupyterLab extension is installed
RUN jupyter labextension install @jupyterlab/server-proxy

COPY jupyter.sh /usr/bin/jupyter.sh

WORKDIR /workspace
RUN git clone https://github.com/myQLM/myqlm-notebooks.git

EXPOSE 8080
ENV HOME /workspace
RUN mkdir $HOME/.local
RUN chown -R 42420:42420 $HOME
ENTRYPOINT []
CMD ["/usr/bin/jupyter.sh"]
