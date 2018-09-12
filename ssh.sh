function ssh_into() {

    local IS_PROD=false
    local POSITIONAL=()
    local BASTION_ADDRESS=
    local HOST_IP=
    local IS_PROD=

    while [[ $# -gt 0 ]]
    do
        local key="$1"

        case $key in
            -b|--bastion)
                BASTION_ADDRESS="$2"
                shift # past argument
                shift # past value
            ;;
            -h|--host)
                HOST_IP="$2"
                shift # past argument
                shift # past value
            ;;
            -p|--prod)
                IS_PROD=true
                shift # past argument
            ;;
            *)    # unknown option
                POSITIONAL+=("$1") # save it in an array for later
                shift # past argument
            ;;
        esac
    done

    BASTION_ADDRESS=${BASTION_ADDRESS:-test-admin}

    if [[ -z $HOST_IP ]]; then
        echo "You need to supply a host IP to connect to"
        usage
        return
    fi

    local ARGS=
    if [[ $IS_PROD = false ]]; then
        if [[ "$BASTION_ADDRESS" == "admin" ]]; then
            echo "you must supply the -p|--prod flag to run against production"
            usage
            return
        fi
        ARGS=${POSITIONAL[*]}
    fi

    if [[ "$SSH_AUTH_SOCK" == "" ]]; then
        eval `ssh-agent`;
        while read id; do ssh-add $(echo $id) ; done<~/.bash_lib/ssh_identities
    fi

    local CMD="ssh -q -t $BASTION_ADDRESS ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$HOST_IP $ARGS"

    echo $CMD

    $CMD

}

function scp_into() {


    local IS_PROD=false
    local POSITIONAL=()
    local BASTION_ADDRESS=
    local HOST_IP=
    local IS_PROD=

    while [[ $# -gt 0 ]]
    do
        local key="$1"

        case $key in
            -b|--bastion)
                BASTION_ADDRESS="$2"
                shift # past argument
                shift # past value
            ;;
            -h|--host)
                HOST_IP="$2"
                shift # past argument
                shift # past value
            ;;
            *)    # unknown option
                POSITIONAL+=("$1") # save it in an array for later
                shift # past argument
            ;;
        esac
    done

    BASTION_ADDRESS=${BASTION_ADDRESS:-test-admin}

    if [[ -z $HOST_IP ]]; then
        echo "You need to supply a host IP to connect to"
        usage
        return
    fi

    local ARGS=
    if [[ $IS_PROD = false ]]; then
        if [[ "$BASTION_ADDRESS" == "admin" ]]; then
            echo "you must supply the -p|--prod flag to run against production"
            usage
            return
        fi
        ARGS=${POSITIONAL[*]}
    fi

    if [[ "$SSH_AUTH_SOCK" == "" ]]; then
        eval `ssh-agent`;
        while read id; do ssh-add $(echo $id) ; done<~/.bash_lib/ssh_identities
    fi

    local CMD="scp -oProxyJump=ec2-user@$BASTION_ADDRESS ${POSITIONAL[*]}  ec2-user@$HOST_IP:~/"

    echo $CMD

    $CMD
}

function scp_out() {

    local IS_PROD=false
    local POSITIONAL=()
    local BASTION_ADDRESS=
    local HOST_IP=
    local IS_PROD=

    while [[ $# -gt 0 ]]
    do
        local key="$1"

        case $key in
            -b|--bastion)
                BASTION_ADDRESS="$2"
                shift # past argument
                shift # past value
            ;;
            -h|--host)
                HOST_IP="$2"
                shift # past argument
                shift # past value
            ;;
            *)    # unknown option
                POSITIONAL+=("$1") # save it in an array for later
                shift # past argument
            ;;
        esac
    done

    BASTION_ADDRESS=${BASTION_ADDRESS:-test-admin}

    if [[ -z $HOST_IP ]]; then
        echo "You need to supply a host IP to connect to"
        usage
        return
    fi

    local ARGS=
    if [[ $IS_PROD = false ]]; then
        if [[ "$BASTION_ADDRESS" == "admin" ]]; then
            echo "you must supply the -p|--prod flag to run against production"
            usage
            return
        fi
        ARGS=${POSITIONAL[*]}
    fi

    if [[ "$SSH_AUTH_SOCK" == "" ]]; then
        eval `ssh-agent`;
        while read id; do ssh-add $(echo $id) ; done<~/.bash_lib/ssh_identities
    fi

    local CMD="scp -oProxyJump=ec2-user@$BASTION_ADDRESS ec2-user@$HOST_IP:${POSITIONAL[*]} ."

    echo $CMD

    $CMD
}

function usage() {
    echo
    echo "usage: ssh_into [-b \$BASTION | test-admin ] [-p] -h \$HOST_IP"
    echo "  -b bastion host to proxy through. Defaults to test-admin."
    echo "  -h the ecs server host to connect to."
    echo "  -p a flag show that you're running against prod."
}

#Aliases
alias sshin=ssh_into
alias scpin=scp_into
alias scpout=scp_out


