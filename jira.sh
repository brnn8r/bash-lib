function _hg_branch_jira() {
    hg branch | sed 's/^\([A-Z]\{3,4\}-[0-9]\+\).*/\1/';
}
function jira() {
    
    JIRA_LOCATION_FILE="jira_location"   

    if [[ ! -r  $JIRA_LOCATION_FILE ]]; then
        echo "could not read jira location from file $JIRA_LOCATION_FILE"
        return
    fi

    jira=$(_hg_branch_jira)
    explorer "$(cat $JIRA_LOCATION_FILE)/browse/$jira"
}

