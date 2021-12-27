#!/bin/bash

set -e

OPTIND=1
usage() {
    echo "Usage: $0 <task name> [<task instance> [command]]" 1>&2
}

while getopts "h" opt; do
    case "$opt" in
        h|*)
            usage
            exit 1
        ;;
    esac
done

exec_task=$1
# Check if task is specified
if [ -z ${exec_task} ]; then
    usage
    exit 1
fi

exec_instance=$2
cmd="${@:3}"
exec_cmd="${cmd:-\/bin\/bash}"

strindex() {
    x="${1%%$2*}"
    [[ "$x" = "$1" ]] && echo -1 || echo "${#x}"
}

parse_node() {
    read title
    id_start=0
    name_start=`strindex "$title" NAME`
    image_start=`strindex "$title" IMAGE`
    node_start=`strindex "$title" NODE`
    dstate_start=`strindex "$title" DESIRED`
    id_length=name_start
    name_length=`expr $image_start - $name_start`
    node_length=`expr $dstate_start - $node_start`

    read line
    id=${line:$id_start:$id_length}
    name=${line:$name_start:$name_length}
    name=$(echo $name)
    node=${line:$node_start:$node_length}
    echo $name.$id
    echo $node
}

if true; then
     read fn
     docker_fullname=$fn
     read nn
     docker_node=$nn
fi < <( docker service ps -f name=$exec_task.$exec_instance --no-trunc -f desired-state=running $exec_task | parse_node )

echo "Executing in $docker_node $docker_fullname"

ssh -t ${docker_node} docker exec -ti $docker_fullname $exec_cmd
