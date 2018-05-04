source "$(dirname ${BASH_SOURCE[0]})/path.sh"

function _hg_branch_jira() {
    hg branch | tail -n 1 | sed 's/^\([A-Z]\{3,4\}-[0-9]\+\).*/\1/';
}
function jira() {

    local DIR=$(script_pwd "${BASH_SOURCE[0]}")

    JIRA_LOCATION_FILE="$DIR/jira_location"

    if [[ ! -r  $JIRA_LOCATION_FILE ]]; then
        echo "could not read jira location from file $JIRA_LOCATION_FILE"
        return
    fi

    jira=$(_hg_branch_jira)
    explorer "$(cat $JIRA_LOCATION_FILE)/browse/$jira"
}

