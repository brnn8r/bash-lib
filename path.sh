function script_pwd() {
    local src="$1"

    echo "$( cd "$( dirname "$src" )" && pwd )"
}

function switch_slash() {
    local path="${1:-$(</dev/stdin)}"

    echo $path | tr '\\' '/'
}

function sym_link() {
    local NODE="$(which node)"

    local FILE="${1:?missing file path}"
    local LINK="${2:?missing link path}"

    [[ -z "$NODE" ]] && echo "requires node to be installed" && return

    eval node -e "'let fs = require(\"fs\"); fs.symlinkSync(\"$FILE\", \"$LINK\", \"junction\")'";
}

alias ss=switch_slash
alias lns=sym_link