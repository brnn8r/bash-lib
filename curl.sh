echo="$(which echo)"
if [[ ! -x $echo ]]; then
    return
fi

curl="$(which curl)"

if [[ ! -x $curl ]]; then
    $echo "Couldn't find curl command!"
    return
fi

function curl_wrapper() {

    local METHOD=
    local URI=
    local CONTENT=
    local BODY=
    local POSITIONAL=

    while [[ $# -gt 0 ]]
    do
        local key="$1"

        case $key in
            -m|--method)
                METHOD="$2"
                shift # past argument
                shift # past value
            ;;
            -u|--uri)
                URI="$2"
                shift # past argument
                shift # past value
            ;;
            -c|--content-type)
                CONTENT="$2"
                shift # past argument
                shift # past value
            ;;
            -b|--body)
                BODY="$2"
                shift # past argument
                shift # past value
            ;;
            *)    # unknown option
                POSITIONAL+=("$1") # save it in an array for later
                shift # past argument
            ;;
        esac
    done

    if [[ ! $URI ]]; then
        $echo "You must provide a URI!"
        return
    fi

    if [[ ! $CONTENT ]]; then
        CONTENT="application/json"
    fi

    if [[ ! $METHOD ]]; then
        METHOD="GET"
    fi

    if [[ ! $BODY && $METHOD == "POST" ]]; then
        $echo "You must provide body data for a POST!"
        return
    elif [[ $METHOD == "POST" ]]; then
        BODY="-d '$BODY'"
        CONTENT="-H \"Content-Type:$CONTENT\""
    fi

    CMD="$curl -kX $METHOD $BODY $CONTENT $URI"
    echo $CMD
    $CMD

}

#Aliases
alias curlw=curl_wrapper
