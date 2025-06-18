#!/bin/bash

echo -e '!!!\nrun "eval $(ssh-agent) && ssh-add ~/.ssh/id_rsa" to stop constant asking of password\n!!!\n'

mkdir -p $TS3D_DOCS
cd $TS3D_DOCS

echo -e "Cloning at $TS3D_DOCS\n"

git clone git@bitbucket.org:techsoft3d/com_docs.git
git clone git@bitbucket.org:techsoft3d/hps_docs.git
git clone git@bitbucket.org:techsoft3d/3df_docs.git
git clone git@bitbucket.org:techsoft3d/hex_docs.git
git clone git@bitbucket.org:techsoft3d/pub_docs.git

echo -e "run 'docs' to go navigate to repos\n"