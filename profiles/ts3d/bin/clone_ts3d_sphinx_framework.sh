#!/bin/bash

echo -e '!!!\nrun "eval $(ssh-agent) && ssh-add ~/.ssh/id_rsa" to stop constant asking of password\n!!!\n'

mkdir -p $TS3D_SPHINX_FRAMEWORK
cd $TS3D_SPHINX_FRAMEWORK

echo -e "Cloning at $TS3D_SPHINX_FRAMEWORK\n"

git clone git@bitbucket.org:techsoft3d/sphinx_template_project.git
git clone git@bitbucket.org:techsoft3d/sphinx_ts3d_ext.git
git clone git@bitbucket.org:techsoft3d/sphinx_ts3d_theme.git
git clone git@bitbucket.org:techsoft3d/jenkins_pipeline_libs.git

echo -e "run 'sph' to navigate to repos\n"