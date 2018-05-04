function remove_exited_docker_processes()
{
    docker="$(which docker)"

    if [[ ! -x $docker ]]; then
        return
    fi

    exited_images=$(docker ps -a -q -f status=exited)
    [[ ! -z $exited_images ]] && docker rm $exited_images
}

function get_docker_id() {

    awk="$(which awk)"
    docker="$(which docker)"
    docker_image_name=$1

    if [[ (-z $docker_image_name) || (! -x $docker) || (! -x $awk) ]]; then
        return
    fi

    docker_image_id=$(docker ps | grep $docker_image_name | $awk '{print $1}')
    echo $docker_image_id

}

#Aliases
alias dockerm="remove_exited_docker_processes"
alias gdi="get_docker_id"