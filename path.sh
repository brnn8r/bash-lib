function script_pwd() {
    local src="$1"

    echo "$( cd "$( dirname "$src" )" && pwd )"
}

function switch_slash() {
    local path="${1:-$(</dev/stdin)}"

    echo $path | tr '\\' '/'
}

alias ss=switch_slash