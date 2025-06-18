#!/bin/bash

echo -e '!!!\nrun "eval $(ssh-agent) && ssh-add ~/.ssh/id_rsa" to stop constant asking of password\n!!!\n'

mkdir -p $TS3D_REPOS
cd $TS3D_REPOS

echo -e "Cloning at $TS3D_REPOS\n"

git clone git@bitbucket.org:techsoft3d/communicator.git && cd communicator && git lfs pull && popd
git clone git@bitbucket.org:techsoft3d/visualize.git && cd visualize && git lfs pull && popd
git clone git@bitbucket.org:techsoft3d/ts3d-flask.git

echo -e "run 'src' to go navigate to repos\n"