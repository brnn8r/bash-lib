function watch_command() {
    local iterations=0
    local sleep=1
    local args=

    while [[ $# -gt 0 ]]
    do
        local key="$1"

        case $key in
            -i|--iterations)
                iterations="$2"
                shift # past argument
                shift # past value
            ;;
            -s|--sleep)
                sleep="$2"
                shift # past argument
                shift # past value
            ;;
            *)    # unknown option
                args+=("$key") # save it in an array for later
                shift # past argument
            ;;
        esac
    done

    local cmd=${args[*]}

    [[ -z $cmd ]] && return

    # while true
    local count=0
    while :
    do
        if [[ $iterations -gt 0 && $count -ge $iterations ]]; then
            return
        fi

        eval $cmd

        count=$(($count + 1))

        sleep $sleep
    done

}

alias watch=watch_command