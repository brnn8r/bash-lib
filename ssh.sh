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
    HOST_IP=${HOST_IP:?"You need to supply a host IP to connect to"}

    local ARGS=
    if [[ $IS_PROD = false ]]; then
        if [[ "$BASTION_ADDRESS" == "admin" ]]; then
            echo "you must supply the -p|--prod flag to run against production"
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
    HOST_IP=${HOST_IP:?"You need to supply a host IP to connect to"}

    if [[ "$SSH_AUTH_SOCK" == "" ]]; then
        eval `ssh-agent`;
        while read id; do ssh-add $(echo $id) ; done<~/.bash_lib/ssh_identities
    fi

    local CMD="scp -oProxyJump=ec2-user@$BASTION_ADDRESS ${POSITIONAL[*]}  ec2-user@$HOST_IP:~/"

    echo $CMD

    $CMD
}

#Aliases
alias sshin=ssh_into
alias scpin=scp_into


