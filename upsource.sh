function upsource() {

    UPSOURCE_LOCATION_FILE="upsource_location"   

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
