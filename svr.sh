function build_clean_start() {

    svr auth generate && svr docker build && svr docker clean && svr docker start
}

function initialize_service() {

    SERVICE_FILE="service.json"
    NODE="$(which node)"

    [[ -r $SERVICE_FILE ]] || (echo "No service.json file found!" && return)

    [[ -x "$NODE" ]] || (echo "This script requires node!" && return)

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

    local BUCKET_NAME=$(cat service.json | jq '.model.bucket.name' | sed -e 's/"//g')
    if [[ "$BUCKET_NAME" == "null" ]]; then
        echo "No .model.bucket.name found in $SERVICE_FILE!"
        return
    fi

    local MODEL_DIR="/models/$BUCKET_NAME/$MODEL_VERSION/"

    [[ -d "$MODEL_DIR" ]] || mkdir -p $MODEL_DIR

    eval node -e "'let fs = require(\"fs\"); fs.symlinkSync(\"$MODEL_DIR\", \"$LINK_DIR\", \"junction\")'";

}

function initialize_logs_link() {

    local LINK_DIR="logs"

    [[ -d $LINK_DIR ]] && return

    local IMAGE_NAME=$(cat service.json | jq '.docker.image.name' | sed -e 's/"//g')
    if [[ "$IMAGE_NAME" == "null" ]]; then
        echo "No .docker.image.name found in $SERVICE_FILE!"
        return
    fi

    LOGS_DIR="/var/log/tm-services/$IMAGE_NAME/"

    [[ -d "$LOGS_DIR" ]] || mkdir -p $LOGS_DIR

    eval node -e "'let fs = require(\"fs\"); fs.symlinkSync(\"$LOGS_DIR\", \"$LINK_DIR\", \"junction\")'";

}

alias initsvr=initialize_service
alias svrbcs=build_clean_start