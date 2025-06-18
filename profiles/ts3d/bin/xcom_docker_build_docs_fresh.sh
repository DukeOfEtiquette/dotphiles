#!/bin/bash

# copy a set of commands to the clipboard then start the Docker container responsible for building Communicator
# the set of commands intentionally left untracked to mitigate leaking secrets
xclip -selection clipboard -i $TS3D/cmds/com_docker_build_docs_fresh.txt
cd $TS3D_COM_REP
./dockerize.sh