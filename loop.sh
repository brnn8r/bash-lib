function loop_command() {

    local ITERATIONS=1
    local POSITIONAL=
    local SRC=

    while [[ $# -gt 0 ]]
    do
        local key="$1"

        case $key in
            -i|--iterations)
                ITERATIONS="$2"
                shift # past argument
                shift # past value
            ;;
            -f|--file)
                SRC="$2"
                shift # past argument
                shift # past value
            ;;
            *)    # unknown option
                POSITIONAL+=("$key") # save it in an array for later
                shift # past argument
            ;;
        esac
    done

    local CMD=${POSITIONAL[*]}

    if [[ ! $CMD && ! $SRC ]]; then
        echo "you must provide a command to loop or a source file with the command to loop"
        return
    fi

    for i in $(seq 1 $ITERATIONS); do
        if [[ $CMD ]]; then
            echo $CMD
            eval $CMD
        elif [[ $SRC ]]; then
            bash $SRC
        fi
    done


}

alias loop=loop_command