#!/bin/bash
script=$(readlink -f $0)
script_loc=$(dirname "$script")

function set_env {
  if [ "$PYTHONPATH" != "." ]; then
    echo "Setting Environment Variables"
    curr_loc="$(pwd)"
    cd "${script_loc}" || exit 1
    cd ../
    set -a
    . .env
    set +a
    cd "${curr_loc}" || exit 1
  fi
}
function project_root {
    echo "$(git rev-parse --show-toplevel)"
}
function module_project_root {
    echo "$(project_root)/$1"
}
function directory_exists {
    if [ -d "$1" ]; then return 0; else return 1; fi
}

function directory_empty {
    if [ -z "$(ls -A "$1")" ]; then return 0; else return 1; fi
}
function file_exists {
    if [ -f "$1" ]; then return 0; else return 1; fi
}


function docker_image_exists {
    if [ -n "$(docker images -q "$1" 2> /dev/null)" ]; then return 0; else return 1; fi
}
function docker_container_running {
    if [ -n "$(docker container ps -q -f name="$1" 2> /dev/null)" ]; then return 0; else return 1; fi
}
function docker_container_exists {
    if [ -n "$(docker container ps -q -f name="$1" -a 2> /dev/null)" ]; then return 0; else return 1; fi

}

function confirm_prompt {
  prompt=$1
while true; do
    read -p "$prompt [y/n]: " yn
    case $yn in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        * ) echo "Please answer y)es or n)o.";;
    esac
  done
}