# Fresh build

Follow these instructions if you are working with a fresh build/user and need to quickly get up and running for TS3D development.

## Pre-reqs

1. Completed the dotfiles install/set up instructions

## Steps

1. Auth terminal session for bitbucket clones: `eval $(ssh-agent) && ssh-add ~/.ssh/id_rsa`

1. Get sphinx docs projects: `. $HOME/bin/clone_ts3d_docs.sh`

1. Get sphinx framework: `. $HOME/bin/clone_ts3d_sphinx_framework.sh`

1. Get TS3D product sources: `. $HOME/bin/clone_ts3d_product_src.sh`

   - This script will **not** verify anything builds correctly
   - Review `$HOME/.zshrc` for aliases that follow the pattern `xcom_docker_build_<>` for verifying builds

Here it is, all in one go:

`eval $(ssh-agent) && ssh-add ~/.ssh/id_rsa && . $HOME/bin/clone_ts3d_docs.sh && . $HOME/bin/clone_ts3d_sphinx_framework.sh && . $HOME/bin/clone_ts3d_product_src.sh`