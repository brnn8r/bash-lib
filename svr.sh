source "$(dirname ${BASH_SOURCE[0]})/path.sh"

function build_clean_start() {

    svr auth generate && svr docker build && svr docker clean && svr docker start
}

function initialize_service() {

    SERVICE_FILE="service.json"
    NODE="$(which node)"

    if [[ ! -r $SERVICE_FILE ]]; then
        echo "No service.json file found!"
        return
    fi

    if [[ ! -x "$NODE" ]]; then
        echo "This script requires node!"
        return
    fi

    initialize_model_link
    initialize_logs_link
}

function initialize_model_link() {

    local LINK_DIR="model"

    [[ -d $LINK_DIR ]] && return

    local MODEL_VERSION=$(cat service.json | jq '.model.version' | sed -e 's/"//g')
    if [[ "$MODEL_VERSION" == "null" ]]; then
        echo "No .model.version found in $SERVICE_FILE!"
        return
    fi

    local BUCKET_NAME=$(cat service.json | jq '.service.clusters[].aws | select(.account_id == 362571885929) | .bucket.name' | sed -e 's/"//g')
    if [[ "$BUCKET_NAME" == "null" ]]; then
        echo "No bucket name found in $SERVICE_FILE!"
        return
    fi

    local MODEL_DIR="c:/models/$BUCKET_NAME/$MODEL_VERSION/"

    [[ -d "$MODEL_DIR" ]] || mkdir -p $MODEL_DIR

    sym_link $MODEL_DIR $LINK_DIR

}

function initialize_logs_link() {

    local LINK_DIR="logs"

    [[ -d $LINK_DIR ]] && return

    local IMAGE_NAME=$(cat service.json | jq '.docker.image.name' | sed -e 's/"//g')
    if [[ "$IMAGE_NAME" == "null" ]]; then
        echo "No .docker.image.name found in $SERVICE_FILE!"
        return
    fi

    LOGS_DIR="c:/var/log/tm-services/$IMAGE_NAME/"

    [[ -d "$LOGS_DIR" ]] || mkdir -p $LOGS_DIR

    sym_link $LOGS_DIR $LINK_DIR

}

alias initsvr=initialize_service
alias svrbcs=build_clean_start