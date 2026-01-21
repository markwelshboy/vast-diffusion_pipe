#!/usr/bin/env bash

touch ~/.no_auto_tmux
umask 0022

# Determine which branch to clone based on environment variables
BRANCH="main"  # Default branch

# Clone the repository to a temporary location with the specified branch
echo "Cloning branch '$BRANCH' from repository..."
git clone --branch "$BRANCH" https://github.com/markwelshboy/vast-diffusion_pipe.git /tmp/vast-diffusion_pipe

# Check if clone was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to clone branch '$BRANCH'. Falling back to main branch..."
    git clone https://github.com/markwelshboy/vast-diffusion_pipe.git /tmp/vast-diffusion_pipe

    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone repository. Exiting..."
        exit 1
    fi
fi

mkdir -p /workspace

# Clone the repository to a temporary location with the specified branch
echo "Cloning branch '$BRANCH' from repository..."
git clone --branch "$BRANCH" https://github.com/markwelshboy/pod-runtime.git /workspace/pod-runtime

# Check if clone was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to clone branch '$BRANCH'. Falling back to main branch..."
    git clone https://github.com/markwelshboy/pod-runtime.git /workspace/pod-runtime

    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone repository. Exiting..."
        exit 1
    fi
fi

# Move start.sh to root and execute it
mv /tmp/vast-diffusion_pipe/src/start.sh /
chmod +x /start.sh
bash /start.sh