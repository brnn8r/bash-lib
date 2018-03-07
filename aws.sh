svr="$(which svr)"

if [[ ! -x $svr ]]; then
    return
fi

#Aliases
alias setprod="$svr set aws.__allow_prod_access__ true"
alias unsetprod="$svr unset aws.__allow_prod_access__"