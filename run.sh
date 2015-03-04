#!/bin/bash

cmd-weave-cli(){
  /usr/local/bin/weave "$@"
}

# proxy back into this container using the docker client
# although cumbersome - this avoids issues like running --net=host and --links
# in the same container which docker does not like
cmd-weave(){
  docker run --rm \
    --net=host \
    --privileged \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /proc:/hostproc \
    -e PROCFS=/hostproc \
    binocarlos/powerstrip-weave weave "$@"
}

# we ensure there is a weavetools container with
# wait-for-weave in a volume
#
# WAIT_FOR_WEAVE_QUIT tells the wait-for-weave binary to quit immediately
# this is for when we just want to volume to be mounted and not for
# anything to actually run
#
cmd-launch(){
  docker run --name weavewait -e "WAIT_FOR_WEAVE_QUIT=yes" binocarlos/wait-for-weave
  cmd-weave launch "$@"
  node /srv/app/index.js
}

# just launch the node server for quick restarts when developing
cmd-softlaunch(){
  node /srv/app/index.js
}

# remove the powerstrip-weave container (or whatever it is called)
# stop weave itself
# remove the weavetools container
cmd-stop(){
  local pluginname=$1
  if [[ -z $pluginname ]]; then
    pluginname="powerstrip-weave"
  fi
  cmd-weave stop
  docker stop $pluginname
  docker rm $pluginname
  docker rm weavewait
}

main() {
  case "$1" in
  launch)             shift; cmd-launch "$@";;
  softlaunch)         shift; cmd-softlaunch "$@";;
  stop)               shift; cmd-stop "$@";;
  weave)              shift; cmd-weave-cli "$@";;
  *)                  cmd-weave "$@";;
  esac
}

main "$@"
