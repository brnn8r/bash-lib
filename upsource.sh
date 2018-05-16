source "$(dirname ${BASH_SOURCE[0]})/path.sh"

function upsource() {

    local DIR=$(script_pwd "${BASH_SOURCE[0]}")

    UPSOURCE_LOCATION_FILE="$DIR/upsource_location"

    if [[ ! -r  $UPSOURCE_LOCATION_FILE ]]; then
        echo "could not read upsource location from file $UPSOURCE_LOCATION_FILE"
        return
    fi

    branch=$(hg branch)
    repo=$(_hg_repo)
    if [[ "$repo" == "TradeMe.FrEnd"* ]]; then
        repo="trademe-frend";
        elif [[ "$repo" == "Product/DataScienceServices"* ]]; then
        repo="datascience-services";
    else
        repo="trademe"
    fi
    explorer "$(cat $UPSOURCE_LOCATION_FILE)/$repo/branch/$branch"
}
