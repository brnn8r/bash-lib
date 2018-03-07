function ssh_into() {
    
    IS_PROD=false
    POSITIONAL=()
    while [[ $# -gt 0 ]]
    do
        key="$1"
        
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
    
    if [[ -z $BASTION_ADDRESS ]]; then
        BASTION_ADDRESS=temp-admin
    fi
    
    if [[ -z $HOST_IP ]]; then
        echo "You need to supply a host IP to connect to"
        return
    fi
    
    ARGS=
    if [[ $IS_PROD = false ]]; then
        if [[ "$BASTION_ADDRESS" == "admin" ]]; then
            echo "you must supply the -p|--prod flag to run against production"
            return
        fi
        ARGS=${POSITIONAL[*]}
    fi
    
    if [[ "$SSH_AUTH_SOCK" == "" ]]; then
        eval `ssh-agent`;
        while read id; do ssh-add $(echo $id) ; done<ssh_identities
    fi
    
    CMD="ssh -q -t $BASTION_ADDRESS ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$HOST_IP $ARGS"
    
    echo $CMD
    
    $CMD
    
}

#Aliases
alias sshin=ssh_into


