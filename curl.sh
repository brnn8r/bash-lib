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

    while [[ $# -gt 0 ]]
    do
        key="$1"

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

    if [[ -z $URI ]]; then
        $echo "You must provide a URI!"
        return
    fi

    if [[ -z $CONTENT ]]; then
        CONTENT="application/json"
    fi

    if [[ -z $METHOD ]]; then
        METHOD="GET"
    fi

    if [[ -z $BODY && $METHOD == "POST" ]]; then
        $echo "You must provide body data for a POST!"
        return
    elif [[ $METHOD == "POST" ]]; then
        BODY_PARAM="-d '$BODY'"
        CONTENT_TYPE_PARAM="-H \"Content-Type:$CONTENT\""
    else
        BODY_PARAM=
        CONTENT_TYPE_PARAM=
    fi

    CMD="$curl -kX $METHOD $BODY_PARAM $CONTENT_TYPE_PARAM $URI"
    echo $CMD
    #$CMD

}

#Aliases
alias curlw=curl_wrapper
