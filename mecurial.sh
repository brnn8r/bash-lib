function _hg_repo() {
    hg path | sed 's/.*tmhg.*\/repo\/\(.*\)/\1/';
}
function hgstat() {
    hg status | awk 'BEGIN{RS="\r\n";FS="\r\n"}
  {
    prefix = substr($1,0,1);

    if      (prefix == "A") $1 = "\033[1;32m" $1;
    else if (prefix == "M") $1 = "\033[1;34m" $1;
    else if (prefix == "R") $1 = "\033[1;31m" $1;
    else if (prefix == "?") $1 = "\033[1;36m" $1;
    else if (prefix == "!") $1 = "\033[1;33m" $1;
    else                    $1 = "\033[1;37m" $1;

    if ( length( $1 ) > 0 )
      print $1 "\033[0m";
    }'
}
function hgst() { hgstat; }

function hglog() {
    LOG=`hg log -r 'reverse(branch(.))' --limit 30 --template "$cCYAN{node|short} $cWHITE| $cMAGENTA{pad(tags,7,'~')} $cWHITE| $cYELLOW{date(date, '%a %d %b %Y %H:%M:%S')} $cWHITE| $cGREEN{author|user}$cWHITE: $cLIGHT_GRAY{desc|strip|firstline}EOL"`;
    echo -e $LOG | sed 's/EOL/\r\n/g' |  sed 's/~/ /g';
}
function hglg() { hglog; }

function br ()
{
    hg branches | grep -i $1 | awk '{print $1}' | awk 'NR==1'
}
function hgup() {
    if [[ $1 ]]; then
        if [[ $1 == "default" ]]; then
            BRANCH="default"
            elif [[ $1 == "v"*"."*"."* ]]; then
            BRANCH=$1
        else
            BRANCH=$(br $1);
        fi
        echo -e $cCYAN"Switching to $BRANCH...";
        hg up $BRANCH;
        echo -n -e $cRESET;
    fi
}

function _hg_parse_stat() {
    commit="$1"
    commit_letter=$2
    output_letter=$3
    count=$(echo "$commit" | awk 'BEGIN{RS=", "}{print $1" "$2}' | awk '/'$commit_letter'/,NF=1');
    if [[ $count -gt 0 ]]; then
        echo " "$output_letter$count;
    fi
}

function _hg_prompt() {


    if [[ ! -z "$CACHED_PROMPT" ]]; then

        DIFF=$(hg diff --nodates --noprefix 2>/dev/null | md5 -n)
        BRANCH=$(hg branch 2>/dev/null | tail -n 1)

        if ([[ "$DIFF" == "$CACHED_DIFF" ]] && [[ "$BRANCH" == "$CACHED_BRANCH" ]]); then
            echo -e "$CACHED_PROMPT"
            return
        fi
    fi

    cRESET="\e[0m";

    cRED="\e[0;31m";
    cGREEN="\e[0;32m";
    cBLUE="\e[0;34m";
    cYELLOW="\e[0;33m";
    cMAGENTA="\e[0;35m";
    cCYAN="\e[0;36m";
    cGRAY="\e[0;37m";

    HG_SUMMARY_SCRIPT="hg.exe summary";
    HG_SUMMARY=$($HG_SUMMARY_SCRIPT 2>&1)
    if [[ $HG_SUMMARY && $HG_SUMMARY != *'not found'* ]]; then
        BRANCH=$(echo "$HG_SUMMARY" | grep branch: | awk 'BEGIN{FS=": "}{print $2}');
        NUM_HEADS=$(echo "$HG_SUMMARY" | grep update: | grep 'branch heads');
        HAS_OUT=$(echo "$HG_SUMMARY" | grep phases:);
        COMMIT=$(echo "$HG_SUMMARY" | grep commit: | sed -e 's/commit: //')

        if [[ $HAS_OUT ]]; then
            out_stats=$cGRAY" *";
        fi

        if [[ $NUM_HEADS ]]; then
            branch=$cRED"[$BRANCH]"
        else
            branch=$cCYAN"[$BRANCH]"
        fi

        IMAGE_VERSION=
        MODEL_VERSION=
        if [[ -r service.json ]]; then
            IMAGE_VERSION="service:$(cat service.json | jq .docker.image.version | tr '"' ' ')"
            MODEL_VERSION="model:$(cat service.json | jq .model.version | tr '"' ' ')"
        fi

        echo -e " \
$branch\
$cGREEN$(_hg_parse_stat "$COMMIT" "added" "+")\
$cBLUE$(_hg_parse_stat "$COMMIT" "modified" "~")\
$cRED$(_hg_parse_stat "$COMMIT" "removed" "-")\
$cCYAN$(_hg_parse_stat "$COMMIT" "renamed" "^")\
$cMAGENTA$(_hg_parse_stat "$COMMIT" "unknown" "?")\
$cYELLOW$(_hg_parse_stat "$COMMIT" "deleted" "!")\
 $IMAGE_VERSION $MODEL_VERSION \
$out_stats\
        $cRESET"
    fi
}

function _collapse_pwd() {
    echo $(pwd | sed -e "s,^\/cygdrive\/,/," | sed -e "s,^$HOME,~," | sed -e "s,^\/\([a-z]\),\u\1:,");
}

function prompter() {
    cRESET="\e[0m";
    cGREEN="\e[0;32m";
    cMAGENTA="\e[0;35m";
    cYELLOW="\e[0;33m";

    export CACHED_PROMPT=$(_hg_prompt)

    PS1=""
    PS1="$PS1\["$cGREEN"\]\h \["$cRESET"\]"
    PS1="$PS1\["$cYELLOW"\]$(_collapse_pwd)\["$cRESET"\]"
    PS1="$PS1\[$CACHED_PROMPT\]"
    PS1="$PS1\r\n"
    PS1="$PS1\["$cGREEN"\]\$ > \["$cRESET"\]"
    export PS1

    export CACHED_DIFF="$(hg diff --nodates --noprefix 2>/dev/null | md5 -n)"
    export CACHED_BRANCH=$(hg branch 2>/dev/null | tail -n 1)
}

PROMPT_COMMAND=prompter