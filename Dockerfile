# Use CUDA base image
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 AS base

ENV SHELL=/bin/bash

# Consolidated environment variables
ENV DEBIAN_FRONTEND=noninteractive \
   PIP_PREFER_BINARY=1 \
   PIP_BREAK_SYSTEM_PACKAGES=1 \
   PYTHONUNBUFFERED=1 \
   CMAKE_BUILD_PARALLEL_LEVEL=8

# Faster transfer of models from the hub to the container
#ENV HF_HUB_ENABLE_HF_TRANSFER="1"
# Set Default Python Version
#ENV PYTHON_VERSION="3.12"

WORKDIR /

# Update and upgrade
RUN apt-get update --yes

# Install basic utilities
RUN apt install --yes --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    file \
    git \
    git-lfs \
    inotify-tools \
    jq \
    libgl1 \
    lsof \
    vim \
    less \
    nano \
    tmux \
    nginx \
    openssh-server \
    procps \
    rsync \
    sudo \
    software-properties-common \
    unzip \
    wget \
    aria2 \
    zip \
    bzip2 \
    ninja-build

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
   python3 python3-pip python3-venv libgl1 libglib2.0-0 \
   python3-dev build-essential gcc \
   && ln -sf /usr/bin/python3 /usr/bin/python \
   && ln -sf /usr/bin/pip3 /usr/bin/pip \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --no-cache-dir gdown jupyterlab jupyterlab-lsp \
    jupyter-server jupyter-server-terminals \
    ipykernel jupyterlab_code_formatter huggingface_hub[cli] \
    ninja packaging

# Cleanup
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Create the final image
FROM base AS final

# Clone the repository in the final stage
RUN pip install torch torchvision torchaudio
RUN git clone --recurse-submodules https://github.com/tdrussell/diffusion-pipe /diffusion_pipe
# Install requirements but exclude flash-attn to avoid build issues
RUN grep -v -i "flash-attn\|flash-attention" /diffusion_pipe/requirements.txt > /tmp/requirements_no_flash.txt && \
    pip install -r /tmp/requirements_no_flash.txt

# Expose ports
EXPOSE 80
EXPOSE 22
EXPOSE 8888

COPY src/start_script.sh /start_script.sh
RUN chmod +x /start_script.sh
CMD ["/start_script.sh"]